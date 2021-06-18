using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    [Authorize]
    //[Route("consultas/estados-de-cuenta/{action}")]
    public class EstadosCuentaController : Controller
    {
        IReportePregradoServiceFacade reporteServiceFacade;
        IProgramasClientFacade programasClientFacade;

        public EstadosCuentaController()
        {
            reporteServiceFacade = new ReportePregradoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
        }

        // GET: EstadosCuenta
        [Route("consultas/estados-de-cuenta")]
        public ActionResult Index()
        {
            ViewBag.Title = "Estados de Cuenta";
            return View();
        }

        //public ActionResult PagosPorFecha()
        //{
        //    var fechaInicio = DateTime.Now;
        //    var fechaFin = DateTime.Now;

        //    var reporte = reporteServiceFacade.ReportePagosGeneralesPorFecha(fechaInicio, fechaFin);

        //    return View(reporte);
        //}

        public ActionResult PagosPregrado(string facultad, string fechaDesde, string fechaHasta, int reporte = 0)
        {
            var fechaInicio = DateTime.Now;
            var fechaFin = DateTime.Now;

            //var fechaInicio1 = DateTime.ParseExact(fechaDesde, "dd/MM/yyyy", CultureInfo.InvariantCulture);
            //var fechaFin1 = DateTime.ParseExact(fechaHasta, "dd/MM/yyyy", CultureInfo.InvariantCulture);

            PagosPregradoViewModel model;

            switch (reporte)
            {
                case 1:
                    var reporte1 = reporteServiceFacade.ReportePagosPorFacultad(fechaInicio, fechaFin);

                    model = new PagosPregradoViewModel(reporte1);

                    break;

                case 2:
                    var reporte2 = reporteServiceFacade.ReportePagosPorConcepto(fechaInicio, fechaFin);

                    model = new PagosPregradoViewModel(reporte2);

                    break;

                case 3:
                    var reporte3 = reporteServiceFacade.ReporteConceptosPorUnaFacultad(facultad, fechaInicio, fechaFin);

                    model = new PagosPregradoViewModel(reporte3);

                    break;

                default:
                    model = null;
                    break;
            }

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            return View(model);
        }
    }
}