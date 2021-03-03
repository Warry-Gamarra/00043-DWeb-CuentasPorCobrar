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
        public JsonResult BuscarObligacionesAlumno(int anio, int periodo, string codigoAlu, string codRc)
        {
            var detalle_pago = obligacionFacade.Obtener_DetallePago(anio, periodo, codigoAlu, codRc);

            var cuotas_pago = obligacionFacade.Obtener_CuotaPago(anio, periodo, codigoAlu, codRc);

            return Json(new { detalle_pago = detalle_pago, cuotas_pago = cuotas_pago }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GenerarArchivosBancos(int anio, int periodo, int tipoAlumno, int nivel)
        {
            var cuotas_pago = obligacionFacade.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoAlumno, nivel);

            MemoryStream memoryStream = new MemoryStream();
            TextWriter tw = new StreamWriter(memoryStream);

            tw.WriteLine("Hello World");
            tw.WriteLine("Hello World");
            tw.Flush();
            tw.Close();

            return File(memoryStream.GetBuffer(), "text/plain", "Obligaciones.txt");
        }
    }
}