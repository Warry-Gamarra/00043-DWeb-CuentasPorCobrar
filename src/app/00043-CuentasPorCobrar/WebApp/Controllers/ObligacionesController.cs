using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApp.Controllers
{
    public class ObligacionesController : Controller
    {
        // GET: Obligaciones
        //[Route("obligaciones/generar")]
        public ActionResult Index()
        {
            ViewBag.Title = "Generar Obligaciones";

            if (TempData["result"] != null)
            {
                var result = (Response)TempData["result"];

                ViewBag.Success = result.Value;
                ViewBag.Message = result.Message;
            }

            return View();
        }

        [HttpPost]
        public ActionResult GenerarObligacionesPregrado(int cmbAnio, int cmbPeriodo)
        {
            var obl = new ObligacionesService();

            var result = obl.Generar_Obligaciones_Pregrado(cmbAnio, cmbPeriodo);

            TempData["result"] = result;

            return RedirectToAction("Index", "Obligaciones");
        }
    }
}