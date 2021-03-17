using Domain.DTO;
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

namespace WebApp.Controllers
{
    public class ObligacionesController : Controller
    {
        IGeneralServiceFacade generalServiceFacade;
        ICatalogoServiceFacade catalogoServiceFacade;
        IObligacionServiceFacade obligacionServiceFacade;
        IAlumnosClientFacade alumnosClientFacade;
        IProgramasClientFacade programasClientFacade;
        
        public ObligacionesController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
        }

        public ActionResult Generar()
        {
            ViewBag.Title = "Generar Obligaciones";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();
            
            if (TempData["result"] == null)
            {
                ViewBag.CurrentYear = DateTime.Now.Year;
                ViewBag.DefaultPeriodo = "15";
                ViewBag.DefaultTipoEstudio = TipoEstudio.Pregrado;
                ViewBag.DefaultFacultad = "";
                ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);
            }
            else
            {
                var result = (Response)TempData["result"];

                ViewBag.CurrentYear = TempData["anio"];
                ViewBag.DefaultPeriodo = TempData["periodo"];
                ViewBag.DefaultTipoEstudio = TempData["tipoEstudio"];
                ViewBag.DefaultFacultad = TempData["facultad"];
                ViewBag.Facultades = programasClientFacade.GetFacultades((TipoEstudio)TempData["tipoEstudio"]);
                ViewBag.Success = result.Value;
                ViewBag.Message = result.Message;
            }

            return View();
        }

        [HttpGet]
        public JsonResult ObtenerFacultades(TipoEstudio tipoEstudio)
        {
            var result = programasClientFacade.GetFacultades(tipoEstudio);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Generar(int cmbAnioGrupal, int cmbPeriodoGrupal, TipoEstudio cmbTipoEstudio, string cmbFacultad)
        {
            Response result;
            int currentUserID;

            try
            {
                switch (cmbTipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        currentUserID = 0;
                        result = obligacionServiceFacade.Generar_Obligaciones_Pregrado(cmbAnioGrupal, cmbPeriodoGrupal, cmbFacultad, currentUserID);
                        break;

                    case TipoEstudio.Posgrado:
                        currentUserID = 0;
                        result = obligacionServiceFacade.Generar_Obligaciones_Posgrado(cmbAnioGrupal, cmbPeriodoGrupal, currentUserID);
                        break;

                    default:
                        throw new Exception("Ha ocurrido un error al seleccionar el Tipo de Estudio.");
                }
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
            TempData["facultad"] = cmbFacultad;

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
            var alumno = alumnosClientFacade.GetEspecialidadesAlumno(codAlu);

            if (alumno == null || alumno.Count() == 0)
            {
                throw new Exception("El alumno no existe.");
            }

            if (alumno.Where(a => a.C_RcCod.Equals(codRc)).FirstOrDefault() == null)
            {
                throw new Exception("El alumno no existe en la especialidad seleccionada.");
            }

            var detalle_pago = obligacionServiceFacade.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            var cuotas_pago = obligacionServiceFacade.Obtener_CuotaPago(anio, periodo, codAlu, codRc);

            return Json(new { detalle_pago = detalle_pago, cuotas_pago = cuotas_pago }, JsonRequestBehavior.AllowGet);
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

            var result = obligacionServiceFacade.Generar_Obligaciones_PorAlumno(anio, periodo, codAlu, codRc, 0);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GenerarArchivosBancos(int anio, int periodo, int tipoAlumno, int nivel)
        {
            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoAlumno, nivel);
            var fecha_actual = DateTime.Now;


            MemoryStream memoryStream = new MemoryStream();
            TextWriter tw = new StreamWriter(memoryStream);

            if (cuotas_pago != null && cuotas_pago.Count > 0)
            {
                #region Cabecera
                string cab = String.Format("T{0:D6}{1:D14}{2:D6}{3:D14}{4:yyyyMMdd}{5:D8}",
                    cuotas_pago.Count(),
                    (int)(cuotas_pago.Sum(c => c.I_MontoTotal) * 100),
                    0,
                    0,
                    fecha_actual,
                    0);

                tw.WriteLine(cab);
                #endregion

                #region Detalle
                foreach (var item in cuotas_pago)
                {
                    string det = String.Format("D0001000{0,-20}{1,-40}{2}{3}00000000{4:yyyyMMdd}{5}{6:D14}{0}{7}{8}{9}{4:yyyyMMdd}{10}{11}{12}{13:D14}{14}{6:D14}{15}",
                        item.C_CodAlu.PadLeft(10, '0'), 
                        item.T_NombresCompletos,
                        item.I_NroOrden.ToString("D5").PadRight(20, ' '),
                        new String(' ', 20), //Referencia del recibo
                        item.D_FecVencto,
                        "01", //Moneda (01=soles y 02=dolares),
                        (int)(item.I_MontoTotal * 100),
                        item.C_CodRc, //Información adicional
                        item.I_Anio,
                        item.C_Periodo,
                        item.I_ProcesoID.ToString().PadLeft(10, ' '),
                        item.I_MontoTotal.Value.ToString("#.00").PadLeft(10, ' '),
                        new String(' ', 4),
                        0, //Interes moratorio
                        item.N_CodBanco.PadRight(4, '0'),
                        new String('0', 162)
                        );
                    tw.WriteLine(det);
                }
                #endregion

            }

            tw.Flush();
            tw.Close();

            return File(memoryStream.GetBuffer(), "text/plain", "Obligaciones.txt");
        }
    }   
}
