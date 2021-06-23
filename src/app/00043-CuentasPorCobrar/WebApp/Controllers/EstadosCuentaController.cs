﻿using Domain.Helpers;
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
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IGeneralServiceFacade generalServiceFacade;

        public EstadosCuentaController()
        {
            reporteServiceFacade = new ReportePregradoServiceFacade();
            reportePosgradoServiceFacade = new ReportePosgradoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
            generalServiceFacade = new GeneralServiceFacade();
        }

        // GET: EstadosCuenta
        [Route("consultas/estados-de-cuenta")]
        public ActionResult Index()
        {
            ViewBag.Title = "Estados de Cuenta";
            return View();
        }

        public ActionResult PagosPregrado(PagosPregradoViewModel model)
        {
            switch (model.reporte)
            {
                case 1:
                    model.reportePagosPorFacultadViewModel = reporteServiceFacade.ReportePagosPorFacultad(model.fechaInicio.Value, model.fechaFin.Value);

                    break;

                case 2:
                    model.reportePagosPorConceptoViewModel = reporteServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value);

                    break;

                case 3:
                    model.reporteConceptosPorUnaFacultadViewModel = reporteServiceFacade.ReporteConceptosPorUnaFacultad(model.facultad, model.fechaInicio.Value, model.fechaFin.Value);

                    break;
            }

            ViewBag.TipoReportes = generalServiceFacade.Listar_ReportesPregrado();

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            return View(model);
        }

        public ActionResult PagosPosgrado(PagosPosgradoViewModel model)
        {
            switch (model.reporte)
            {
                case 1:
                    model.reportePagosPorGradodViewModel = reportePosgradoServiceFacade.ReportePagosPorGrado(model.fechaInicio.Value, model.fechaFin.Value);

                    break;

                case 2:
                    model.reportePagosPorConceptoPosgradoViewModel = reportePosgradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value);

                    break;

                case 3:
                    model.reporteConceptosPorGradoViewModel = reportePosgradoServiceFacade.ReporteConceptosPorGrado(model.posgrado, model.fechaInicio.Value, model.fechaFin.Value);

                    break;
            }

            ViewBag.TipoReportes = generalServiceFacade.Listar_ReportesPosgrado();

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Posgrado);

            return View(model);
        }
    }
}