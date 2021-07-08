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

        public ObligacionesController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
            matriculaServiceFacade = new MatriculaServiceFacade();
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

            var cuotas_pago = obligacionServiceFacade.Obtener_CuotaPago(anio, periodo, codAlu, codRc);

            detalle_pago.ForEach(d => {
                d.I_NroOrden = cuotas_pago.Find(c => c.I_ObligacionAluID == d.I_ObligacionAluID).I_NroOrden;
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
    }   
}
