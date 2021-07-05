using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    [Authorize]
    //[Route("consultas/estados-de-cuenta/{action}")]
    public class EstadosCuentaController : Controller
    {
        IReportePregradoServiceFacade reporteServiceFacade;
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IGeneralServiceFacade generalServiceFacade;
        SelectModel selectModels;

        public EstadosCuentaController()
        {
            reporteServiceFacade = new ReportePregradoServiceFacade();
            reportePosgradoServiceFacade = new ReportePosgradoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
            generalServiceFacade = new GeneralServiceFacade();
            selectModels = new SelectModel();
        }

        // GET: EstadosCuenta
        [Route("consultas/estados-de-cuenta")]
        public ActionResult Index()
        {
            ViewBag.Title = "Estados de Cuenta";
            return View();
        }

        [Route("consultas/estados-de-cuenta-pregrado")]
        public ActionResult PagosPregrado(PagosPregradoViewModel model)
        {
            switch (model.reporte)
            {
                case 1:
                    model.reportePagosPorFacultadViewModel = reporteServiceFacade.ReportePagosPorFacultad(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                    break;

                case 2:
                    model.reportePagosPorConceptoViewModel = reporteServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                    break;

                case 3:
                    model.reporteConceptosPorUnaFacultadViewModel = reporteServiceFacade.ReporteConceptosPorUnaFacultad(model.facultad, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                    break;
            }

            ViewBag.TipoReportes = generalServiceFacade.Listar_ReportesPregrado();

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            ViewBag.EntidadesFinancieras = selectModels.GetEntidadesFinancieras();

            ViewBag.Title = "Reportes de Pago de Obligaciones de Pregrado";

            return View(model);
        }

        [Route("consultas/estados-de-cuenta-posgrado")]
        public ActionResult PagosPosgrado(PagosPosgradoViewModel model)
        {
            switch (model.reporte)
            {
                case 1:
                    model.reportePagosPorGradodViewModel = reportePosgradoServiceFacade.ReportePagosPorGrado(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                    break;

                case 2:
                    model.reportePagosPorConceptoPosgradoViewModel = reportePosgradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                    break;

                case 3:
                    model.reporteConceptosPorGradoViewModel = reportePosgradoServiceFacade.ReporteConceptosPorGrado(model.posgrado, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                    break;
            }

            ViewBag.TipoReportes = generalServiceFacade.Listar_ReportesPosgrado();

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Posgrado);

            ViewBag.EntidadesFinancieras = selectModels.GetEntidadesFinancieras();

            ViewBag.Title = "Reportes de Pago de Obligaciones de Posgrado";

            return View(model);
        }
    }
}