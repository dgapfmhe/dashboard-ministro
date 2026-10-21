/* Web Worker: Python (Pyodide) + statsmodels en el navegador.
 * Ejecuta /lab/laboratorio.py — el MISMO motor que usan los pronósticos oficiales
 * en GitHub Actions. Mensajes:
 *   ← {tipo:'iniciar'}                      → {tipo:'estado', texto} … {tipo:'listo'}
 *   ← {tipo:'correr', id, payload}          → {tipo:'progreso', id, f, nombre} … {tipo:'resultado', id, data}
 *                                            → {tipo:'error', id, mensaje}
 */
const PYODIDE = 'https://cdn.jsdelivr.net/pyodide/v0.27.2/full/'
importScripts(PYODIDE + 'pyodide.js')

let listo = null

async function iniciar(version) {
  postMessage({ tipo: 'estado', texto: 'Cargando Python (Pyodide)…' })
  const py = await loadPyodide({ indexURL: PYODIDE })
  postMessage({ tipo: 'estado', texto: 'Cargando numpy, pandas, scipy y statsmodels…' })
  await py.loadPackage(['numpy', 'pandas', 'scipy', 'statsmodels'])
  postMessage({ tipo: 'estado', texto: 'Cargando el motor del laboratorio…' })
  const codigo = await (await fetch('/lab/laboratorio.py?v=' + encodeURIComponent(version || ''))).text()
  py.FS.writeFile('/home/pyodide/laboratorio.py', codigo)
  py.runPython('import sys, json; sys.path.insert(0, "/home/pyodide"); import laboratorio')
  postMessage({ tipo: 'listo' })
  return py
}

onmessage = async (ev) => {
  const m = ev.data
  try {
    if (!listo) listo = iniciar(m.version)
    const py = await listo
    if (m.tipo !== 'correr') return
    py.globals.set('payload_json', JSON.stringify(m.payload))
    py.globals.set('js_progreso', (f, nombre) => postMessage({ tipo: 'progreso', id: m.id, f, nombre }))
    const salida = py.runPython(
      'json.dumps(laboratorio.correr(json.loads(payload_json), progreso=lambda f, n: js_progreso(f, n)))')
    postMessage({ tipo: 'resultado', id: m.id, data: JSON.parse(salida) })
  } catch (e) {
    let msg = String(e && e.message ? e.message : e)
    const i = msg.lastIndexOf('Error:')
    if (msg.includes('Traceback') && i >= 0) msg = msg.slice(msg.lastIndexOf('\n', i) + 1).trim()
    postMessage({ tipo: 'error', id: m.id, mensaje: msg })
  }
}
