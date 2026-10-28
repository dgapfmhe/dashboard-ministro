/* Web Worker: Python (Pyodide) + statsmodels + scikit-learn en el navegador.
 * Ejecuta /lab/laboratorio.py — el MISMO motor que usan los pronósticos oficiales
 * en GitHub Actions. Mensajes:
 *   ← {tipo:'iniciar'}                      → {tipo:'estado', texto} … {tipo:'listo'}
 *   ← {tipo:'correr', id, payload}          → {tipo:'progreso', id, f, nombre} … {tipo:'resultado', id, data}
 *                                            → {tipo:'error', id, mensaje}
 */
const PYODIDE = 'https://cdn.jsdelivr.net/pyodide/v0.27.2/full/'
const PAQUETES = ['numpy', 'pandas', 'scipy', 'statsmodels', 'scikit-learn']
importScripts(PYODIDE + 'pyodide.js')

let listo = null

async function iniciar(version) {
  postMessage({ tipo: 'estado', texto: 'Cargando Python (Pyodide)…' })
  const py = await loadPyodide({ indexURL: PYODIDE })
  // loadPackage NO lanza error si un paquete no se descarga (red inestable):
  // se verifica importándolos y se reintenta.
  for (let intento = 1; intento <= 3; intento++) {
    postMessage({ tipo: 'estado', texto: intento === 1
      ? 'Cargando numpy, pandas, scipy, statsmodels y scikit-learn…'
      : `Reintentando la descarga de librerías (${intento}/3)…` })
    await py.loadPackage(PAQUETES, { errorCallback: (m) => console.warn('[pyodide]', m) })
    try {
      py.runPython('import numpy, pandas, scipy, statsmodels.api, sklearn')
      break
    } catch (e) {
      if (intento === 3) {
        throw new Error('No se pudieron descargar las librerías de Python (statsmodels / scikit-learn). ' +
                        'Revisa la conexión a internet y vuelve a pulsar «Correr laboratorio».')
      }
      await new Promise(r => setTimeout(r, 3000 * intento))
    }
  }
  postMessage({ tipo: 'estado', texto: 'Cargando el motor del laboratorio…' })
  const codigo = await (await fetch('/lab/laboratorio.py?v=' + encodeURIComponent(version || ''))).text()
  py.FS.writeFile('/home/pyodide/laboratorio.py', codigo)
  py.runPython('import sys, json, importlib; sys.path.insert(0, "/home/pyodide"); import laboratorio; importlib.reload(laboratorio)')
  postMessage({ tipo: 'listo' })
  return py
}

onmessage = async (ev) => {
  const m = ev.data
  try {
    if (!listo) listo = iniciar(m.version)
    let py
    try {
      py = await listo
    } catch (e) {
      listo = null            // permite reintentar en el próximo mensaje
      throw e
    }
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
