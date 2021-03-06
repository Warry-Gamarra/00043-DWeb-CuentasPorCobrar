using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;

namespace WebApp.Controllers
{
    public class ObligacionesController : Controller
    {
        ProcesoModel procesoModel;
        ConceptoPagoModel conceptoPagoModel;
        ObligacionFacade obligacionFacade;

        public ObligacionesController()
        {
            procesoModel = new ProcesoModel();
            conceptoPagoModel = new ConceptoPagoModel();
            obligacionFacade = new ObligacionFacade();
        }

        public ActionResult Generar()
        {
            ViewBag.Title = "Generar Obligaciones";

            if (TempData["result"] != null)
            {
                var result = (Response)TempData["result"];

                ViewBag.Success = result.Value;
                ViewBag.Message = result.Message;
            }

            ViewBag.Anios = procesoModel.Listar_Anios();

            ViewBag.Periodos = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Periodo);

            return View();
        }

        [HttpPost]
        public ActionResult Generar(int cmbAnioGrupal, int cmbPeriodoGrupal)
        {
            var result = obligacionFacade.Generar_Obligaciones_Pregrado(cmbAnioGrupal, cmbPeriodoGrupal, 0);

            TempData["result"] = result;

            ViewBag.Lista_Anios = procesoModel.Listar_Anios();

            return RedirectToAction("Generar", "Obligaciones");
        }

        [HttpPost]
        public JsonResult GenerarPorAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            var result = obligacionFacade.Generar_Obligaciones_PorAlumno(anio, periodo, codAlu, codRc, 0);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [HandleJsonExceptionAttribute]
        public JsonResult BuscarObligacionesAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            var alumno = obligacionFacade.Obtener_Especialidades_X_Alumno(codAlu);

            if (alumno == null || alumno.Count == 0)
            {
                throw new Exception("El alumno no existe.");
            }

            var detalle_pago = obligacionFacade.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            var cuotas_pago = obligacionFacade.Obtener_CuotaPago(anio, periodo, codAlu, codRc);

            return Json(new { detalle_pago = detalle_pago, cuotas_pago = cuotas_pago }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult Obtener_Especialidades_X_Alumno(string codAlu)
        {
            var result = obligacionFacade.Obtener_Especialidades_X_Alumno(codAlu);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GenerarArchivosBancos(int anio, int periodo, int tipoAlumno, int nivel)
        {
            var cuotas_pago = obligacionFacade.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoAlumno, nivel);
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

    public class HandleJsonExceptionAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            if (filterContext.HttpContext.Request.IsAjaxRequest() && filterContext.Exception != null)
            {
                filterContext.HttpContext.Response.StatusCode = (int)System.Net.HttpStatusCode.InternalServerError;
                filterContext.Result = new JsonResult()
                {
                    JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                    Data = new
                    {
                        filterContext.Exception.Message,
                        filterContext.Exception.StackTrace
                    }
                };
                filterContext.ExceptionHandled = true;
            }
        }
    }
}