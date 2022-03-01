using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
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

        public ActionResult Generar(int? cmbAnioGrupal, int? cmbPeriodoGrupal, string cmbDependencia, TipoEstudio cmbTipoEstudio = TipoEstudio.Pregrado)
        {
            ViewBag.Title = "Generar Obligaciones";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

            IEnumerable<CuotaPagoModel> cuotas_pago;

            if (TempData["result"] == null)
            {
                ViewBag.CurrentYear = DateTime.Now.Year;
                ViewBag.DefaultPeriodo = "15";
                ViewBag.DefaultTipoEstudio = cmbTipoEstudio;
                ViewBag.DefaultDependencia = "";
                ViewBag.Dependencias = programasClientFacade.GetFacultades(cmbTipoEstudio);

                if (cmbAnioGrupal.HasValue && cmbPeriodoGrupal.HasValue)
                    cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago_X_Proceso(cmbAnioGrupal.Value, cmbPeriodoGrupal.Value, cmbTipoEstudio, cmbDependencia);
                else
                    cuotas_pago = new List<CuotaPagoModel>();
            }
            else
            {
                var result = (Response)TempData["result"];

                ViewBag.CurrentYear = TempData["anio"];
                ViewBag.DefaultPeriodo = TempData["periodo"];
                ViewBag.DefaultTipoEstudio = TempData["tipoEstudio"];
                ViewBag.DefaultDependencia = TempData["dependencia"];
                ViewBag.Dependencias = programasClientFacade.GetFacultades((TipoEstudio)TempData["tipoEstudio"]);
                ViewBag.Success = result.Value;
                ViewBag.Message = result.Message;

                cuotas_pago = new List<CuotaPagoModel>();
            }

            return View(cuotas_pago);
        }

        [HttpPost]
        public ActionResult Generar(int cmbAnioGrupal, int cmbPeriodoGrupal, TipoEstudio cmbTipoEstudio, string cmbDependencia)
        {
            Response result;
            int currentUserID;

            try
            {
                currentUserID = WebSecurity.CurrentUserId;

                result = obligacionServiceFacade.Generar_Obligaciones(cmbAnioGrupal, cmbPeriodoGrupal, cmbTipoEstudio, cmbDependencia, currentUserID);
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
            TempData["anio"] = cmbAnioGrupal;
            TempData["periodo"] = cmbPeriodoGrupal;
            TempData["tipoEstudio"] = cmbTipoEstudio;
            TempData["dependencia"] = cmbDependencia;

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
            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(), "Value", "TextDisplay", model.tipoEstudio);
            ViewBag.Dependencias = new SelectList(programasClientFacade.GetDependencias(model.tipoEstudio), "Value", "TextDisplay", model.codFac);
            ViewBag.Escuelas = new SelectList(programasClientFacade.GetEscuelas(model.codFac), "Value", "TextDisplay", model.codEsc);
            ViewBag.Especialidades = new SelectList(programasClientFacade.GetEspecialidades(model.codFac, model.codEsc), "Value", "TextDisplay", model.codRc);
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
        public ActionResult AnularCuotaPago(int obligacionID)
        {
            Response response = new Response()
            {
                Value = false
            };

            var cuotaPago = obligacionServiceFacade.Obtener_CuotaPago(obligacionID);

            if (cuotaPago == null)
            {
                response.Message = "La cuota seleccionada no existe.";
            }
            else if (cuotaPago.B_Pagado)
            {
                response.Message = "No se puede anular el registro porque esta cuota ya ha sido pagada.";
            }
            else if (cuotaPago.I_MontoPagadoActual > 0)
            {
                response.Message = "No se puede anular el registro porque esta cuota tiene un pago incompleto";
            }
            else
            {
                response = obligacionServiceFacade.AnularObligacion(obligacionID, WebSecurity.CurrentUserId);
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }
    }
}
