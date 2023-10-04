using DocumentFormat.OpenXml.EMMA;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
    public class ObligacionesController : Controller
    {
        IGeneralServiceFacade generalServiceFacade;
        ICatalogoServiceFacade catalogoServiceFacade;
        IObligacionServiceFacade obligacionServiceFacade;
        IAlumnosClientFacade alumnosClientFacade;
        IProgramasClientFacade programasClientFacade;
        IMatriculaServiceFacade matriculaServiceFacade;
        IReportePregradoServiceFacade reportePregradoServiceFacade;
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;
        SelectModel selectModels;
        PagosModel pagosModel;

        public ObligacionesController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
            matriculaServiceFacade = new MatriculaServiceFacade();

            reportePregradoServiceFacade = new ReportePregradoServiceFacade();
            reportePosgradoServiceFacade = new ReportePosgradoServiceFacade();

            selectModels = new SelectModel();
            pagosModel = new PagosModel();
        }

        public ActionResult Generar(int? anio, int? periodo, string dependencia, bool? esIngresante, bool? sinObligaciones, bool soloAplicarExtmp = false, TipoEstudio tipoEstudio = TipoEstudio.Pregrado)
        {
            int defaultAño, defaultPeriodo;

            TipoEstudio defaultTipoEstudio;
            
            bool? defaultEsIngresante, defaultSinObligaciones;

            string deFaultDependencia;

            IEnumerable<EstadoObligacionViewModel> cuotas_pago;

            if (TempData["result"] == null)
            {
                defaultAño = anio ?? DateTime.Now.Year;
                defaultPeriodo = periodo ?? (int)Periodos.Anual;
                defaultTipoEstudio = tipoEstudio;
                deFaultDependencia = dependencia ?? "";
                defaultEsIngresante = esIngresante;
                defaultSinObligaciones = sinObligaciones ?? true;

                if (anio.HasValue && periodo.HasValue)
                {
                    var model = new ConsultaObligacionEstudianteViewModel()
                    {
                        anio = defaultAño,
                        periodo = defaultPeriodo,
                        esIngresante = defaultEsIngresante,
                        soloAplicarExtmp = soloAplicarExtmp
                    };

                    if (defaultSinObligaciones.Value)
                    {
                        model.obligacionGenerada = false;
                    }

                    switch (defaultTipoEstudio)
                    {
                        case TipoEstudio.Pregrado:
                            model.codFac = dependencia == "" ? null : dependencia;
                            cuotas_pago = reportePregradoServiceFacade.EstadoObligacionAlumnos(model);
                            break;

                        case TipoEstudio.Posgrado:
                            model.codEsc = dependencia == "" ? null : dependencia;
                            cuotas_pago = reportePosgradoServiceFacade.EstadoObligacionAlumnos(model);
                            break;
                        default:
                            cuotas_pago = new List<EstadoObligacionViewModel>();
                            break;

                    }
                }
                else
                    cuotas_pago = new List<EstadoObligacionViewModel>();
            }
            else
            {
                var result = (Response)TempData["result"];

                defaultAño = (int)TempData["anio"];
                defaultPeriodo = (int)TempData["periodo"];
                defaultTipoEstudio = (TipoEstudio)TempData["tipoEstudio"];
                deFaultDependencia = (string)TempData["dependencia"];
                defaultEsIngresante = (bool?)TempData["esIngresante"];
                defaultSinObligaciones = (bool)TempData["sinObligaciones"];
                soloAplicarExtmp = (bool)TempData["soloAplicarExtmp"];

                ViewBag.Success = result.Value;
                ViewBag.Message = result.Message;

                cuotas_pago = new List<EstadoObligacionViewModel>();
            }

            ViewBag.Title = "Generar Obligaciones";

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay", defaultAño);

            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay", defaultPeriodo);

            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(null), "Value", "TextDisplay", defaultTipoEstudio);

            ViewBag.Dependencias = new SelectList(programasClientFacade.GetFacultades(defaultTipoEstudio, null), "Value", "TextDisplay", deFaultDependencia);

            ViewBag.TipoAlumno = new SelectList(generalServiceFacade.Listar_TipoAlumno(), "Value", "TextDisplay", defaultEsIngresante);

            ViewBag.TieneObligacion = new SelectList(generalServiceFacade.Listar_CondicionAlumnoObligacion(), "Value", "TextDisplay", defaultSinObligaciones);

            ViewBag.CondicionGeneracion = new SelectList(generalServiceFacade.Listar_CondicionGeneracion(), "Value", "TextDisplay", soloAplicarExtmp);

            return View(cuotas_pago);
        }

        [HttpPost]
        public ActionResult Generar(int anio, int periodo, TipoEstudio tipoEstudio, string dependencia, bool? esIngresante, bool sinObligaciones, bool soloAplicarExtmp)
        {
            Response result;
            int currentUserID;

            try
            {
                currentUserID = WebSecurity.CurrentUserId;

                result = obligacionServiceFacade.Generar_Obligaciones(anio, periodo, tipoEstudio, dependencia, esIngresante, sinObligaciones, soloAplicarExtmp, currentUserID);
            }
            catch (Exception ex)
            {
                result = new Response()
                {
                    Value = false,
                    Message = ex.Message
                };
            }
            
            TempData["result"] = result;
            TempData["anio"] = anio;
            TempData["periodo"] = periodo;
            TempData["tipoEstudio"] = tipoEstudio;
            TempData["dependencia"] = dependencia;
            TempData["esIngresante"] = esIngresante; 
            TempData["sinObligaciones"] = sinObligaciones;
            TempData["soloAplicarExtmp"] = soloAplicarExtmp;

            return RedirectToAction("Generar", "Obligaciones");
        }

        [HttpGet]
        [HandleJsonExceptionAttribute]
        public JsonResult ObtenerEspecialidadesAlumno(string codAlu)
        {
            var result = alumnosClientFacade.GetEspecialidadesAlumno(codAlu);

            if (result == null || result.Count() == 0)
            {
                throw new Exception("El alumno no existe.");
            }

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [HandleJsonExceptionAttribute]
        public JsonResult BuscarObligacionesAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            var alumno_especialidades = alumnosClientFacade.GetEspecialidadesAlumno(codAlu);

            if (alumno_especialidades == null || alumno_especialidades.Count() == 0)
            {
                throw new Exception("El alumno no existe.");
            }

            if (alumno_especialidades.Where(a => a.C_RcCod.Equals(codRc)).FirstOrDefault() == null)
            {
                throw new Exception("El alumno no existe en la especialidad seleccionada.");
            }

            var alumno = alumnosClientFacade.GetByID(codRc, codAlu);

            var detalle_pago = obligacionServiceFacade.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago(anio, periodo, codAlu, codRc);

            cuotas_pago.ForEach(x => {
                var pago = pagosModel.ListarPagosBancoPorObligacion(x.I_ObligacionAluID).OrderByDescending(p => p.D_FecPago).FirstOrDefault();
                x.T_Banco = (pago == null) ? "" : pago.T_EntidadDesc;
                x.T_CtaDeposito = (pago == null) ? "" : pago.C_NumeroCuenta;
            });
                
            detalle_pago.ForEach(d => {
                d.I_NroOrden = cuotas_pago.Find(c => c.I_ObligacionAluID == d.I_ObligacionAluID).I_NroOrden;
                var pago = pagosModel.ObtenerPagoObligacionDetalle(d.I_ObligacionAluDetID).OrderByDescending(p => p.D_FecPago).FirstOrDefault();
                d.T_NroRecibo = (pago == null) ? "" : pago.C_CodOperacion;
                d.D_FecPago = (pago == null) ? "" : (pago.D_FecPago.HasValue ? pago.D_FecPago.Value.ToString(FormatosDateTime.BASIC_DATETIME) : "");
                d.T_LugarPago = (pago == null) ? "" : pago.T_LugarPago;
            });

            return Json(new { alumno = alumno, detalle_pago = detalle_pago, cuotas_pago = cuotas_pago }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [HandleJsonExceptionAttribute]
        public JsonResult GenerarObligacionesAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            var alumno = alumnosClientFacade.GetEspecialidadesAlumno(codAlu);

            if (alumno == null || alumno.Count() == 0)
            {
                throw new Exception("El alumno no existe.");
            }

            if (alumno.Where(a => a.C_RcCod.Equals(codRc)).FirstOrDefault() == null)
            {
                throw new Exception("El alumno no existe en la especialidad seleccionada.");
            }

            int currentUserID = WebSecurity.CurrentUserId;

            var result = obligacionServiceFacade.Generar_Obligaciones_PorAlumno(anio, periodo, codAlu, codRc, alumno.First().N_Grado, currentUserID);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [Route("operaciones/obligaciones-generadas")]
        public ActionResult ConsultaGeneracionObligaciones(ConsultaObligacionEstudianteViewModel model)
        {
            ViewBag.Title = "Obligaciones Generadas";

            if (model.anio.HasValue)
            {
                model.obligacionGenerada = true;
                model.fechaDesde = null;
                model.fechaHasta = null;

                switch (model.tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        model.resultado = reportePregradoServiceFacade.EstadoObligacionAlumnos(model);
                        break;

                    case TipoEstudio.Posgrado:
                        model.resultado = reportePosgradoServiceFacade.EstadoObligacionAlumnos(model);
                        break;
                }
            }

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay", model.anio.HasValue ? model.anio.Value : DateTime.Now.Year);
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay", model.periodo);
            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(null), "Value", "TextDisplay", model.tipoEstudio);
            ViewBag.Dependencias = new SelectList(programasClientFacade.GetDependencias(model.tipoEstudio, null), "Value", "TextDisplay", model.codFac);
            ViewBag.Escuelas = new SelectList(programasClientFacade.GetEscuelas(model.tipoEstudio, model.codFac), "Value", "TextDisplay", model.codEsc);
            ViewBag.Especialidades = new SelectList(programasClientFacade.GetEspecialidades(model.tipoEstudio, model.codFac, model.codEsc), "Value", "TextDisplay", model.codRc);
            ViewBag.TipoAlumno = new SelectList(generalServiceFacade.Listar_TipoAlumno(), "Value", "TextDisplay", model.esIngresante);
            ViewBag.EstadoPagoObligaciones = new SelectList(generalServiceFacade.Listar_CondicionPagoObligacion(), "Value", "TextDisplay", model.estaPagado);
            ViewBag.FiltroDependencias = (model.tipoEstudio == TipoEstudio.Posgrado) ? null : "TODOS";

            return View(model);
        }

        public ActionResult EditarDetalleObligacion(int obligacionID)
        {
            var obligacion = obligacionServiceFacade.Obtener_CuotaPago(obligacionID);

            var detalleObligacion = obligacionServiceFacade.Obtener_DetalleObligacion_X_Obligacion(obligacionID);

            ViewBag.Title = "Detalle Obligaciones";

            ViewBag.Obligacion = obligacion;

            ViewBag.DetalleObligacion = detalleObligacion;

            ViewBag.TipoDocumento = new SelectList(selectModels.GetTipoDocumentos(), "Value", "TextDisplay");

            return PartialView("_VerDetalleObligacion");
        }

        [HttpPost]
        [HandleJsonExceptionAttribute]
        public ActionResult ActualizarConceptoObligacion(int obligacionAluDetID, decimal monto, int tipoDocumento, string documento)
        {
            Response response = null;

            var detalleObligacion = obligacionServiceFacade.Obtener_DetalleObligacion_X_ID(obligacionAluDetID);

            if (detalleObligacion == null)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El concepto seleccionado no existe."
                };
            }
            else if (detalleObligacion.B_Pagado)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El concepto ya ha sido pagado, por lo que no se puede modificar su monto."
                };
            }
            else if (String.IsNullOrWhiteSpace(documento))
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El campo Descripción es obligatorio."
                };
            }
            else
            {
                response = obligacionServiceFacade.ActualizarMontoObligaciones(obligacionAluDetID, monto, tipoDocumento, documento, WebSecurity.CurrentUserId);
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [HandleJsonExceptionAttribute]
        public ActionResult AnularCuotaPago(int[] obligaciones)
        {
            Thread.Sleep(500);

            Response response = new Response()
            {
                Value = false
            };

            if (obligaciones == null || obligaciones.Length == 0)
            {
                response.Message = "Debe seleccionar al menos una cuota de pago.";
            }
            else
            {
                int cantErrores = 0;

                foreach (var idObligacion in obligaciones)
                {
                    var cuotaPago = obligacionServiceFacade.Obtener_CuotaPago(idObligacion);

                    if (cuotaPago == null)
                    {
                        response.Message = "La cuota seleccionada no existe.";

                        cantErrores++;
                    }
                    else if (cuotaPago.B_Pagado)
                    {
                        response.Message = "No se puede anular el registro porque esta cuota ya ha sido pagada.";

                        cantErrores++;
                    }
                    else if (cuotaPago.I_MontoPagadoSinMora > 0)
                    {
                        response.Message = "No se puede anular el registro porque esta cuota tiene un pago incompleto";

                        cantErrores++;
                    }
                    else
                    {
                        response = obligacionServiceFacade.AnularObligacion(idObligacion, WebSecurity.CurrentUserId);
                    }
                }

                if (obligaciones.Length > 1)
                {
                    if (cantErrores > 0)
                    {
                        response.Message = "No se logró anular " + cantErrores + " cuota(s) de pago.";
                    }
                    else
                    {
                        response.Message = "Obligaciones anuladas correctamente.";
                    }

                    response.Value = !(obligaciones.Length == cantErrores);
                }
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }
    }
}
