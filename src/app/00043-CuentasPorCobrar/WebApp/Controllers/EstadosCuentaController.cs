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
        IReportePregradoServiceFacade reportePregradoServiceFacade;
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IGeneralServiceFacade generalServiceFacade;
        SelectModel selectModels;

        public EstadosCuentaController()
        {
            reportePregradoServiceFacade = new ReportePregradoServiceFacade();
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

        [Route("consultas/reporte-pago-de-obligaciones")]
        public ActionResult ReportesPagoObligaciones(ReportePagosObligacionesViewModel model)
        {
            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

            ViewBag.Dependencias = programasClientFacade.GetFacultades(model.tipoEstudio);

            ViewBag.EntidadesFinancieras = selectModels.GetEntidadesFinancieras();

            if (model.tipoEstudio == TipoEstudio.Pregrado)
            {
                switch (model.reporte)
                {
                    case 1:
                        model.reportePagosPorFacultadViewModel = reportePregradoServiceFacade.ReportePagosPorFacultad(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                        break;

                    case 2:
                        model.reportePagosPorConceptoViewModel = reportePregradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                        break;

                    case 3:
                        model.reporteConceptosPorUnaFacultadViewModel = reportePregradoServiceFacade.ReporteConceptosPorUnaFacultad(model.dependencia, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                        break;
                }

                ViewBag.Title = "Reportes de Pago de Obligaciones de Pregrado";

                ViewBag.TipoReportes = generalServiceFacade.Listar_ReportesPregrado();
            }

            if (model.tipoEstudio == TipoEstudio.Posgrado)
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
                        model.reporteConceptosPorGradoViewModel = reportePosgradoServiceFacade.ReporteConceptosPorGrado(model.dependencia, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);

                        break;
                }

                ViewBag.Title = "Reportes de Pago de Obligaciones de Posgrado";

                ViewBag.TipoReportes = generalServiceFacade.Listar_ReportesPosgrado();
            }

            return View(model);
        }

        [Route("consultas/resumen-anual-obligaciones-por-clasificadores")]
        public ActionResult ResumenAnualObligacionesPorClasificadores(int anio = 0, TipoEstudio tipoEstudio = TipoEstudio.Pregrado, int? entidadFinanID = null, int? ctaDepositoID = null)
        {
            anio = anio == 0 ? DateTime.Now.Year : anio;

            ReporteResumenAnualPagoObligaciones_X_Clasificadores model;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    model = reportePregradoServiceFacade.ResumenAnualPagoOblig_X_Clasificadores(anio, entidadFinanID, ctaDepositoID);
                    break;

                case TipoEstudio.Posgrado:
                    model = reportePosgradoServiceFacade.ResumenAnualPagoOblig_X_Clasificadores(anio, entidadFinanID, ctaDepositoID);
                    break;
                default:
                    model = new ReporteResumenAnualPagoObligaciones_X_Clasificadores();
                    break;
            }

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay", anio);

            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(), "Value", "TextDisplay", tipoEstudio);

            ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", entidadFinanID);

            ViewBag.CtaDeposito = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay", ctaDepositoID);

            ViewBag.Title = "Resumen de Ingresos por Clasificadores (Obligaciones)";

            return View(model);
        }

        [Route("consultas/resumen-anual-obligaciones-por-dependencias")]
        public ActionResult ResumenAnualObligacionesPorDependencias(int anio = 0, TipoEstudio tipoEstudio = TipoEstudio.Pregrado, int? entidadFinanID = null, int? ctaDepositoID = null)
        {
            anio = anio == 0 ? DateTime.Now.Year : anio;

            ReporteResumenAnualPagoObligaciones_X_Dependencias model;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    model = reportePregradoServiceFacade.ResumenAnualPagoOblig_X_Dependencias(anio, entidadFinanID, ctaDepositoID);
                    break;

                case TipoEstudio.Posgrado:
                    model = reportePosgradoServiceFacade.ResumenAnualPagoOblig_X_Dependencias(anio, entidadFinanID, ctaDepositoID);
                    break;
                default:
                    model = new ReporteResumenAnualPagoObligaciones_X_Dependencias();
                    break;
            }

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay", anio);

            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(), "Value", "TextDisplay", tipoEstudio);

            ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", entidadFinanID);

            ViewBag.CtaDeposito = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay", ctaDepositoID);

            ViewBag.Title = "Resumen de Ingresos por Dependencias (Obligaciones)";

            return View(model);
        }
    }
}