using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;

namespace WebApp.Controllers
{
    [Authorize]
    //[Route("consultas/estados-de-cuenta/{action}")]
    public class EstadosCuentaController : Controller
    {
        IReporteServiceFacade reporteServiceFacade;

        public EstadosCuentaController()
        {
            reporteServiceFacade = new ReporteServiceFacade();
        }

        // GET: EstadosCuenta
        [Route("consultas/estados-de-cuenta")]
        public ActionResult Index()
        {
            ViewBag.Title = "Estados de Cuenta";
            return View();
        }

        public ActionResult PagosPorFecha()
        {
            var fechaInicio = DateTime.Now;
            var fechaFin = DateTime.Now;

            var reporte = reporteServiceFacade.ReportePagosGeneralesPorFecha(fechaInicio, fechaFin);

            return View(reporte);
        }

        public ActionResult PagosPorFacultad()
        {
            var fechaInicio = DateTime.Now;
            var fechaFin = DateTime.Now;

            var reporte = reporteServiceFacade.ReportePagosPorFacultadYFechaViewModel("IN", fechaInicio, fechaFin);

            return View(reporte);
        }
    }
}