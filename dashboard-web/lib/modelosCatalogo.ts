/* Catálogo de modelos del Laboratorio: descripción, supuestos y parámetros editables.
 * Los nombres de parámetros coinciden con public/lab/laboratorio.py. */

export type Familia = 'referencia' | 'econometrico' | 'ml' | 'combinacion'
export type Param =
  | { k: string; etiqueta: string; tipo: 'int'; min: number; max: number; def: number; ayuda?: string; hp?: boolean }
  | { k: string; etiqueta: string; tipo: 'num'; min: number; max: number; paso: number; def: number; ayuda?: string; hp?: boolean }
  | { k: string; etiqueta: string; tipo: 'sel'; opciones: [string, string][]; def: string; ayuda?: string; hp?: boolean }
  | { k: string; etiqueta: string; tipo: 'bool'; def: boolean; ayuda?: string; hp?: boolean }
  | { k: string; etiqueta: string; tipo: 'txt'; def: string; ayuda?: string; hp?: boolean }

export type FichaModelo = {
  tipo: string; nombre: string; familia: Familia
  ecuacion: string; descripcion: string; supuestos: string; cuando: string; limites: string
  usaExog: string
  params: Param[]
}

const DUMMIES: Param = { k: 'dummies', etiqueta: 'Incluir dummies', tipo: 'bool', def: true,
  ayuda: 'Usa las dummies definidas en la sección 4 (estacionales e intervenciones).' }
const LAGS_ML: Param = { k: 'p', etiqueta: 'Rezagos de y', tipo: 'int', min: 0, max: 12, def: 3,
  ayuda: 'Cuántos valores pasados de la variable objetivo entran como variables.' }

export const CATALOGO: FichaModelo[] = [
  /* ── referencia ─────────────────────────────────────────────── */
  {
    tipo: 'rw', nombre: 'Paseo aleatorio', familia: 'referencia', ecuacion: 'ŷ(t+1) = y(t)',
    descripcion: 'Pronostica que el próximo valor será igual al último observado.',
    supuestos: 'Ninguno; es la referencia mínima.', cuando: 'Siempre: es la vara contra la que se mide todo. Muy difícil de vencer en series persistentes (tasas interanuales, tipo de cambio).',
    limites: 'No usa información adicional.', usaExog: 'No', params: [],
  },
  {
    tipo: 'media', nombre: 'Media histórica', familia: 'referencia', ecuacion: 'ŷ(t+1) = media(y)',
    descripcion: 'Pronostica el promedio de la muestra de entrenamiento.',
    supuestos: 'Serie estacionaria alrededor de una media fija.', cuando: 'Series de cambios (m/m) sin persistencia.',
    limites: 'Ignora la dinámica reciente.', usaExog: 'No', params: [],
  },
  {
    tipo: 'ar', nombre: 'AR(p) automático', familia: 'referencia', ecuacion: 'y(t) = c + Σ φᵢ·y(t−i) + ε(t)',
    descripcion: 'Autorregresivo con el número de rezagos elegido por AIC en cada ventana. Es la referencia econométrica estándar.',
    supuestos: 'Estacionariedad; errores ruido blanco.', cuando: 'Siempre como referencia (la investigación muestra que el ISEC no le gana en IPC/IMAE agregados).',
    limites: 'Solo usa el pasado de la propia serie.', usaExog: 'No',
    params: [{ k: 'pmax', etiqueta: 'Rezagos máximos', tipo: 'int', min: 1, max: 12, def: 6 }],
  },
  /* ── econométricos ──────────────────────────────────────────── */
  {
    tipo: 'arima', nombre: 'ARIMA(p,d,q)', familia: 'econometrico',
    ecuacion: 'φ(L)·(1−L)^d·y(t) = c + θ(L)·ε(t) [+ dummies]',
    descripcion: 'Autorregresivo integrado de medias móviles (Box-Jenkins), estimado por máxima verosimilitud con filtro de Kalman.',
    supuestos: 'Tras d diferencias la serie es estacionaria; errores ruido blanco; raíces fuera del círculo unitario.',
    cuando: 'Series univariadas con autocorrelación; base para comparar con SARIMAX.',
    limites: 'No usa el sentimiento ni otras exógenas (solo dummies).', usaExog: 'Solo dummies',
    params: [
      { k: 'p', etiqueta: 'p (AR)', tipo: 'int', min: 0, max: 6, def: 1 },
      { k: 'd', etiqueta: 'd (diferencias)', tipo: 'int', min: 0, max: 2, def: 0 },
      { k: 'q', etiqueta: 'q (MA)', tipo: 'int', min: 0, max: 6, def: 1 },
      { k: 'tendencia', etiqueta: 'Tendencia', tipo: 'sel', def: '', opciones: [['', 'auto'], ['n', 'ninguna'], ['c', 'constante'], ['t', 'lineal'], ['ct', 'constante + lineal']] },
      DUMMIES,
    ],
  },
  {
    tipo: 'sarimax', nombre: 'SARIMAX', familia: 'econometrico',
    ecuacion: 'φ(L)Φ(Lˢ)(1−L)^d(1−Lˢ)^D·y(t) = c + β′x(t) + θ(L)Θ(Lˢ)·ε(t)',
    descripcion: 'ARIMA estacional con regresores exógenos (sentimiento, otras variables y dummies). Es el modelo de prediccionesIPC.ipynb.',
    supuestos: 'Como ARIMA; exógenas conocidas en t+1 (por eso el sentimiento puede entrar en t).',
    cuando: 'Medir si el sentimiento aporta sobre la dinámica propia de la serie.',
    limites: 'Relación lineal y constante en el tiempo.', usaExog: 'Sí',
    params: [
      { k: 'p', etiqueta: 'p', tipo: 'int', min: 0, max: 6, def: 1 },
      { k: 'd', etiqueta: 'd', tipo: 'int', min: 0, max: 2, def: 0 },
      { k: 'q', etiqueta: 'q', tipo: 'int', min: 0, max: 6, def: 1 },
      { k: 'P', etiqueta: 'P (AR est.)', tipo: 'int', min: 0, max: 2, def: 0 },
      { k: 'D', etiqueta: 'D (dif. est.)', tipo: 'int', min: 0, max: 1, def: 0 },
      { k: 'Q', etiqueta: 'Q (MA est.)', tipo: 'int', min: 0, max: 2, def: 0 },
      { k: 's', etiqueta: 's (período)', tipo: 'int', min: 1, max: 12, def: 12 },
      { k: 'tendencia', etiqueta: 'Tendencia', tipo: 'sel', def: '', opciones: [['', 'auto'], ['n', 'ninguna'], ['c', 'constante'], ['t', 'lineal'], ['ct', 'constante + lineal']] },
      DUMMIES,
    ],
  },
  {
    tipo: 'arx', nombre: 'ARX (MCO)', familia: 'econometrico',
    ecuacion: 'y(t) = c + Σ φᵢ·y(t−i) + β′x(t) + ε(t)',
    descripcion: 'Regresión lineal por mínimos cuadrados con rezagos de y y regresores. Transparente: R², F, Durbin-Watson.',
    supuestos: 'Linealidad; exogeneidad de x; errores sin autocorrelación (o usar HAC).',
    cuando: 'Lectura directa de cuánto mueve el sentimiento a la variable (coeficiente β).',
    limites: 'Lineal; sensible a multicolinealidad.', usaExog: 'Sí',
    params: [
      { k: 'p', etiqueta: 'Rezagos de y', tipo: 'int', min: 0, max: 12, def: 2 },
      { k: 'hac', etiqueta: 'Errores robustos HAC (Newey-West)', tipo: 'bool', def: false },
      DUMMIES,
    ],
  },
  {
    tipo: 'var', nombre: 'VAR(p)', familia: 'econometrico',
    ecuacion: 'Y(t) = c + Σ Aᵢ·Y(t−i) + B·D(t) + u(t),  Y = (y, exógenas)',
    descripcion: 'Vector autorregresivo: objetivo y regresores se explican mutuamente con sus rezagos (como el VAR del notebook). Reporta estabilidad y causalidad de Granger.',
    supuestos: 'Todas las series estacionarias; solo usa información rezagada.',
    cuando: 'Estudiar retroalimentación sentimiento ↔ macro y causalidad de Granger.',
    limites: 'No aprovecha el sentimiento contemporáneo del mes a pronosticar; muchos parámetros.', usaExog: 'Como endógenas',
    params: [
      { k: 'p', etiqueta: 'Rezagos', tipo: 'sel', def: 'auto', opciones: [['auto', 'auto (AIC)'], ['1', '1'], ['2', '2'], ['3', '3'], ['4', '4'], ['6', '6']] },
      { k: 'pmax', etiqueta: 'Máx. para auto', tipo: 'int', min: 1, max: 12, def: 4 },
      DUMMIES,
    ],
  },
  /* ── machine learning ───────────────────────────────────────── */
  {
    tipo: 'ridge', nombre: 'Ridge', familia: 'ml', ecuacion: 'min ‖y − Xβ‖² + α‖β‖²',
    descripcion: 'Regresión lineal con penalización L2: encoge los coeficientes y estabiliza con muchos regresores correlacionados.',
    supuestos: 'Relación aproximadamente lineal.', cuando: 'Muchos regresores (sectores, dummies) y pocas observaciones.',
    limites: 'No hace selección de variables.', usaExog: 'Sí',
    params: [LAGS_ML, { k: 'alpha', etiqueta: 'α (penalización)', tipo: 'num', min: 0.0001, max: 1000, paso: 0.1, def: 1, hp: true }, DUMMIES],
  },
  {
    tipo: 'lasso', nombre: 'Lasso', familia: 'ml', ecuacion: 'min ‖y − Xβ‖² + α‖β‖₁',
    descripcion: 'Penalización L1: lleva a cero los coeficientes irrelevantes (selección automática de variables).',
    supuestos: 'Pocas variables realmente relevantes.', cuando: 'Saber cuáles regresores sobreviven (¿queda el sentimiento?).',
    limites: 'Inestable con regresores muy correlacionados.', usaExog: 'Sí',
    params: [LAGS_ML, { k: 'alpha', etiqueta: 'α (penalización)', tipo: 'num', min: 0.00001, max: 10, paso: 0.001, def: 0.01, hp: true }, DUMMIES],
  },
  {
    tipo: 'enet', nombre: 'Elastic Net', familia: 'ml', ecuacion: 'min ‖y − Xβ‖² + α[ρ‖β‖₁ + (1−ρ)/2‖β‖²]',
    descripcion: 'Combina Ridge y Lasso.', supuestos: 'Relación aproximadamente lineal.',
    cuando: 'Selección de variables con regresores correlacionados.', limites: 'Dos hiperparámetros a calibrar.', usaExog: 'Sí',
    params: [LAGS_ML,
      { k: 'alpha', etiqueta: 'α', tipo: 'num', min: 0.00001, max: 10, paso: 0.001, def: 0.01, hp: true },
      { k: 'l1_ratio', etiqueta: 'ρ (proporción L1)', tipo: 'num', min: 0, max: 1, paso: 0.05, def: 0.5, hp: true }, DUMMIES],
  },
  {
    tipo: 'rf', nombre: 'Random Forest', familia: 'ml', ecuacion: 'ŷ = promedio de B árboles de regresión (bagging)',
    descripcion: 'Promedio de muchos árboles entrenados con remuestreo: capta no linealidades e interacciones.',
    supuestos: 'Ninguno paramétrico.', cuando: 'Sospecha de efectos no lineales (p. ej. el sentimiento solo importa en estrés).',
    limites: 'No extrapola fuera del rango visto; necesita más datos.', usaExog: 'Sí',
    params: [LAGS_ML,
      { k: 'n_estimators', etiqueta: 'Árboles', tipo: 'int', min: 10, max: 1000, def: 300, hp: true },
      { k: 'max_depth', etiqueta: 'Profundidad máx. (0 = sin límite)', tipo: 'int', min: 0, max: 30, def: 0, hp: true },
      { k: 'min_samples_leaf', etiqueta: 'Mín. obs. por hoja', tipo: 'int', min: 1, max: 30, def: 3, hp: true },
      { k: 'max_features', etiqueta: 'Variables por división', tipo: 'sel', def: '1.0', hp: true, opciones: [['1.0', 'todas'], ['0.5', '50%'], ['sqrt', '√p'], ['log2', 'log₂p']] },
      DUMMIES],
  },
  {
    tipo: 'gbr', nombre: 'Gradient Boosting', familia: 'ml', ecuacion: 'ŷ = Σ ν·árbolₘ (cada árbol corrige el error del anterior)',
    descripcion: 'Árboles secuenciales que aprenden de los residuos: suele ser el más preciso entre los de árboles.',
    supuestos: 'Ninguno paramétrico.', cuando: 'No linealidades con buena regularización.',
    limites: 'Sobreajusta si la tasa de aprendizaje es alta; no extrapola.', usaExog: 'Sí',
    params: [LAGS_ML,
      { k: 'n_estimators', etiqueta: 'Iteraciones', tipo: 'int', min: 10, max: 2000, def: 200, hp: true },
      { k: 'learning_rate', etiqueta: 'Tasa de aprendizaje ν', tipo: 'num', min: 0.001, max: 1, paso: 0.01, def: 0.05, hp: true },
      { k: 'max_depth', etiqueta: 'Profundidad', tipo: 'int', min: 1, max: 10, def: 2, hp: true },
      { k: 'subsample', etiqueta: 'Submuestra', tipo: 'num', min: 0.1, max: 1, paso: 0.05, def: 0.8, hp: true },
      { k: 'loss', etiqueta: 'Pérdida', tipo: 'sel', def: 'squared_error', hp: true, opciones: [['squared_error', 'cuadrática'], ['absolute_error', 'absoluta'], ['huber', 'Huber (robusta)']] },
      DUMMIES],
  },
  {
    tipo: 'svr', nombre: 'SVR', familia: 'ml', ecuacion: 'ŷ = Σ αᵢ·K(xᵢ, x) + b  (pérdida ε-insensible)',
    descripcion: 'Máquina de soporte vectorial para regresión con núcleo: flexible y robusta a atípicos.',
    supuestos: 'Variables estandarizadas (se hace automático).', cuando: 'Muestras pequeñas con relación no lineal suave.',
    limites: 'Sensible a C, ε y γ.', usaExog: 'Sí',
    params: [LAGS_ML,
      { k: 'C', etiqueta: 'C (regularización)', tipo: 'num', min: 0.001, max: 1000, paso: 0.1, def: 1, hp: true },
      { k: 'epsilon', etiqueta: 'ε (margen)', tipo: 'num', min: 0, max: 2, paso: 0.01, def: 0.05, hp: true },
      { k: 'kernel', etiqueta: 'Núcleo', tipo: 'sel', def: 'rbf', hp: true, opciones: [['rbf', 'RBF'], ['linear', 'lineal'], ['poly', 'polinomial'], ['sigmoid', 'sigmoide']] },
      { k: 'gamma', etiqueta: 'γ', tipo: 'sel', def: 'scale', hp: true, opciones: [['scale', 'scale'], ['auto', 'auto']] },
      DUMMIES],
  },
  {
    tipo: 'knn', nombre: 'K vecinos (KNN)', familia: 'ml', ecuacion: 'ŷ = promedio de y en los k períodos más parecidos',
    descripcion: 'Busca en la historia los meses con condiciones más parecidas (análogos) y promedia lo que pasó después.',
    supuestos: 'Situaciones parecidas producen resultados parecidos.', cuando: 'Razonamiento por analogías históricas.',
    limites: 'Pobre con muchas variables; no extrapola.', usaExog: 'Sí',
    params: [LAGS_ML,
      { k: 'n_neighbors', etiqueta: 'k vecinos', tipo: 'int', min: 1, max: 50, def: 7, hp: true },
      { k: 'weights', etiqueta: 'Ponderación', tipo: 'sel', def: 'distance', hp: true, opciones: [['distance', 'por distancia'], ['uniform', 'uniforme']] },
      DUMMIES],
  },
  {
    tipo: 'mlp', nombre: 'Red neuronal (MLP)', familia: 'ml', ecuacion: 'ŷ = W₂·g(W₁·x + b₁) + b₂',
    descripcion: 'Perceptrón multicapa: aproximador no lineal general.',
    supuestos: 'Suficientes datos para estimar muchos pesos.', cuando: 'Experimentar; en series macro mensuales cortas suele sobreajustar.',
    limites: 'Muchos parámetros para ~120 observaciones; resultados variables.', usaExog: 'Sí',
    params: [LAGS_ML,
      { k: 'capas', etiqueta: 'Neuronas por capa (ej. 16,8)', tipo: 'txt', def: '16,8', hp: true },
      { k: 'activation', etiqueta: 'Activación', tipo: 'sel', def: 'relu', hp: true, opciones: [['relu', 'ReLU'], ['tanh', 'tanh'], ['logistic', 'logística']] },
      { k: 'alpha', etiqueta: 'α (L2)', tipo: 'num', min: 0, max: 10, paso: 0.001, def: 0.001, hp: true },
      { k: 'learning_rate_init', etiqueta: 'Tasa de aprendizaje', tipo: 'num', min: 0.0001, max: 0.1, paso: 0.001, def: 0.005, hp: true },
      { k: 'max_iter', etiqueta: 'Iteraciones máx.', tipo: 'int', min: 100, max: 10000, def: 1500, hp: true },
      DUMMIES],
  },
]

/* Combinaciones (no se agregan como modelo: se eligen en «Combinación de modelos») */
CATALOGO.push(
  { tipo: 'comb_promedio', nombre: 'Promedio simple', familia: 'combinacion', ecuacion: 'ŷ = (1/M) Σ ŷₘ',
    descripcion: 'Promedia los pronósticos de los modelos elegidos con igual peso.',
    supuestos: 'Ninguno; diversifica errores de especificación.', cuando: 'Casi siempre: suele ser difícil de vencer (el "puzzle de la combinación").',
    limites: 'Un modelo muy malo arrastra el promedio.', usaExog: 'Las de sus modelos', params: [] },
  { tipo: 'comb_mediana', nombre: 'Mediana de modelos', familia: 'combinacion', ecuacion: 'ŷ = mediana(ŷ₁ … ŷ_M)',
    descripcion: 'Toma la mediana de los pronósticos: robusta a un modelo extremo.',
    supuestos: 'Ninguno.', cuando: 'Cuando algún modelo diverge mucho (p. ej. redes o árboles inestables).',
    limites: 'Ignora el desempeño relativo.', usaExog: 'Las de sus modelos', params: [] },
  { tipo: 'comb_inv_mse', nombre: 'Promedio ponderado (1/ECM)', familia: 'combinacion', ecuacion: 'ŷ = Σ wₘ ŷₘ,  wₘ ∝ 1/ECMₘ',
    descripcion: 'Pondera cada modelo por la inversa de su error cuadrático medio fuera de muestra. En la evaluación, los pesos de cada período usan solo errores anteriores.',
    supuestos: 'El desempeño pasado informa el futuro.', cuando: 'Cuando hay diferencias claras y estables de precisión entre modelos.',
    limites: 'Pesos ruidosos con pocas evaluaciones.', usaExog: 'Las de sus modelos', params: [] },
)

export const FICHA = Object.fromEntries(CATALOGO.map(c => [c.tipo, c])) as Record<string, FichaModelo>
export const NOMBRE_FAMILIA: Record<Familia, string> = {
  combinacion: 'Combinación',
  referencia: 'Referencia', econometrico: 'Econométrico', ml: 'Machine learning',
}

/** Spec por defecto para un tipo (los hiperparámetros ML van dentro de `hp`). */
export function specPorDefecto(tipo: string, id: string): Record<string, unknown> {
  const f = FICHA[tipo]
  const spec: Record<string, unknown> = { id, tipo }
  const hp: Record<string, unknown> = {}
  for (const p of f?.params ?? []) {
    if (p.hp) hp[p.k] = p.def
    else spec[p.k] = p.def
  }
  if (Object.keys(hp).length) spec.hp = hp
  return spec
}

/** Etiquetas legibles para las propiedades que devuelve el motor. */
export const ETIQUETA_PROP: Record<string, string> = {
  n_obs: 'Observaciones', k_parametros: 'Parámetros estimados', aic: 'AIC', bic: 'BIC', hqic: 'HQIC', fpe: 'FPE',
  log_verosimilitud: 'Log-verosimilitud', sigma2: 'Varianza del error (σ²)', r2: 'R²', r2_ajustado: 'R² ajustado',
  f_p_valor: 'Prueba F (p)', durbin_watson: 'Durbin-Watson', numero_condicion: 'Número de condición', errores: 'Errores estándar',
  orden: 'Orden (p,d,q)', orden_estacional: 'Orden estacional (P,D,Q,s)', modulo_raices_ar: '|raíces AR|',
  modulo_raices_ma: '|raíces MA|', estacionario: 'Estacionario', invertible: 'Invertible', estable: 'Estable (VAR)',
  regresores: 'Regresores', rezagos: 'Rezagos', variables: 'Variables endógenas', 'determinísticas': 'Determinísticas',
  granger_exogenas_a_y_p: 'Granger: exógenas → y (p)', desv_cambios: 'Desv. est. de los cambios', media: 'Media',
  desv_estandar: 'Desv. estándar', rezagos_y: 'Rezagos de y', n_variables: 'Variables de entrada',
  r2_entrenamiento: 'R² entrenamiento', rmse_entrenamiento: 'RMSE entrenamiento', importancia_tipo: 'Tipo de importancia',
  nota: 'Nota',
}
