using ClosedXML.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
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
    [Authorize(Roles = "Administrador, Consulta")]
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

        [Route("consultas/resumen-anual-obligaciones-por-clasificadores/descargar")]
        public ActionResult DescargaResumenAnualObligacionesPorClasificadores(int anio, TipoEstudio tipoEstudio, int? entidadFinanID = null, int? ctaDepositoID = null)
        {
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

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Clasificadores");

                worksheet.Column("A").Width = 14;

                worksheet.Column("B").Width = 30;

                worksheet.Columns("C:O").Width = 14;

                var titleCell = worksheet.Cell(1, 1);

                titleCell.Value = "RESUMEN DE INGRESOS DE " + model.tipoEstudio.ToString().ToUpper() + " AL AÑO " + model.anio;

                titleCell.RichText.SetBold(true);

                titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                worksheet.Range(titleCell, worksheet.Cell(1, 15)).Merge(true);

                var bankNameCell = worksheet.Cell(3, 1);

                bankNameCell.Value = String.IsNullOrEmpty(model.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + model.nombreEntidadFinanc;

                var dateCell = worksheet.Cell(3, 15);

                dateCell.Value = "Fecha consulta: " + model.FechaActual;

                dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                var timeCell = worksheet.Cell(4, 15);

                timeCell.Value = "Hora consulta: " + model.HoraActual;

                timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                var currentRow = 6;

                worksheet.Cell(currentRow, 1).Value = "Clasificador";
                worksheet.Cell(currentRow, 2).Value = "Descripción";
                worksheet.Cell(currentRow, 3).Value = "Enero";
                worksheet.Cell(currentRow, 4).Value = "Febrero";
                worksheet.Cell(currentRow, 5).Value = "Marzo";
                worksheet.Cell(currentRow, 6).Value = "Abril";
                worksheet.Cell(currentRow, 7).Value = "Mayo";
                worksheet.Cell(currentRow, 8).Value = "Junio";
                worksheet.Cell(currentRow, 9).Value = "Julio";
                worksheet.Cell(currentRow, 10).Value = "Agosto";
                worksheet.Cell(currentRow, 11).Value = "Setiembre";
                worksheet.Cell(currentRow, 12).Value = "Octubre";
                worksheet.Cell(currentRow, 13).Value = "Noviembre";
                worksheet.Cell(currentRow, 14).Value = "Diciembre";
                worksheet.Cell(currentRow, 15).Value = "Total (S/.)";

                currentRow++;

                var inicial = currentRow;

                foreach (var item in model.resumen_x_clasificadores)
                {
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodClasificador);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.T_ClasificadorDesc);
                    worksheet.Cell(currentRow, 3).SetValue<decimal>(item.Enero);
                    worksheet.Cell(currentRow, 4).SetValue<decimal>(item.Febrero);
                    worksheet.Cell(currentRow, 5).SetValue<decimal>(item.Marzo);
                    worksheet.Cell(currentRow, 6).SetValue<decimal>(item.Abril);
                    worksheet.Cell(currentRow, 7).SetValue<decimal>(item.Mayo);
                    worksheet.Cell(currentRow, 8).SetValue<decimal>(item.Junio);
                    worksheet.Cell(currentRow, 9).SetValue<decimal>(item.Julio);
                    worksheet.Cell(currentRow, 10).SetValue<decimal>(item.Agosto);
                    worksheet.Cell(currentRow, 11).SetValue<decimal>(item.Setiembre);
                    worksheet.Cell(currentRow, 12).SetValue<decimal>(item.Octubre);
                    worksheet.Cell(currentRow, 13).SetValue<decimal>(item.Noviembre);
                    worksheet.Cell(currentRow, 14).SetValue<decimal>(item.Diciembre);
                    worksheet.Cell(currentRow, 15).SetValue<decimal>(model.TotalClasificador(item.C_CodClasificador));

                    currentRow++;
                }

                worksheet.Cell(currentRow, 2).Value = "Total (S/.)";
                worksheet.Cell(currentRow, 3).SetValue<decimal>(model.TotalEnero);
                worksheet.Cell(currentRow, 4).SetValue<decimal>(model.TotalFebrero);
                worksheet.Cell(currentRow, 5).SetValue<decimal>(model.TotalMarzo);
                worksheet.Cell(currentRow, 6).SetValue<decimal>(model.TotalAbril);
                worksheet.Cell(currentRow, 7).SetValue<decimal>(model.TotalMayo);
                worksheet.Cell(currentRow, 8).SetValue<decimal>(model.TotalJunio);
                worksheet.Cell(currentRow, 9).SetValue<decimal>(model.TotalJulio);
                worksheet.Cell(currentRow, 10).SetValue<decimal>(model.TotalAgosto);
                worksheet.Cell(currentRow, 11).SetValue<decimal>(model.TotalSetiembre);
                worksheet.Cell(currentRow, 12).SetValue<decimal>(model.TotalOctubre);
                worksheet.Cell(currentRow, 13).SetValue<decimal>(model.TotalNoviembre);
                worksheet.Cell(currentRow, 14).SetValue<decimal>(model.TotalDiciembre);
                worksheet.Cell(currentRow, 15).SetValue<decimal>(model.TotalGeneral);

                worksheet.Range(worksheet.Cell(inicial, 3), worksheet.Cell(currentRow, 15)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);

                    var content = stream.ToArray();

                    string nombreArchivo = "Resumen Clasificadores " + tipoEstudio.ToString() + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", nombreArchivo);
                }
            }
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

        [Route("consultas/resumen-anual-obligaciones-por-dependencias/descargar")]
        public ActionResult DescargaResumenAnualObligacionesPorDependencias(int anio, TipoEstudio tipoEstudio, int? entidadFinanID = null, int? ctaDepositoID = null)
        {
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

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Dependencias");

                worksheet.Column("A").Width = 30;

                worksheet.Columns("B:N").Width = 14;

                var titleCell = worksheet.Cell(1, 1);

                titleCell.Value = "RESUMEN DE INGRESOS DE " + model.tipoEstudio.ToString().ToUpper() + " AL AÑO " + model.anio;

                titleCell.RichText.SetBold(true);

                titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                worksheet.Range(titleCell, worksheet.Cell(1, 14)).Merge(true);

                var bankNameCell = worksheet.Cell(3, 1);

                bankNameCell.Value = String.IsNullOrEmpty(model.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + model.nombreEntidadFinanc;

                var dateCell = worksheet.Cell(3, 14);

                dateCell.Value = "Fecha consulta: " + model.FechaActual;

                dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                var timeCell = worksheet.Cell(4, 14);

                timeCell.Value = "Hora consulta: " + model.HoraActual;

                timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                var currentRow = 6;

                worksheet.Cell(currentRow, 1).Value = "Dependencia";
                worksheet.Cell(currentRow, 2).Value = "Enero";
                worksheet.Cell(currentRow, 3).Value = "Febrero";
                worksheet.Cell(currentRow, 4).Value = "Marzo";
                worksheet.Cell(currentRow, 5).Value = "Abril";
                worksheet.Cell(currentRow, 6).Value = "Mayo";
                worksheet.Cell(currentRow, 7).Value = "Junio";
                worksheet.Cell(currentRow, 8).Value = "Julio";
                worksheet.Cell(currentRow, 9).Value = "Agosto";
                worksheet.Cell(currentRow, 10).Value = "Setiembre";
                worksheet.Cell(currentRow, 11).Value = "Octubre";
                worksheet.Cell(currentRow, 12).Value = "Noviembre";
                worksheet.Cell(currentRow, 13).Value = "Diciembre";
                worksheet.Cell(currentRow, 14).Value = "Total (S/.)";

                currentRow++;

                var inicial = currentRow;

                foreach (var item in model.resumen_x_dependencias)
                {
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.T_Dependencia);
                    worksheet.Cell(currentRow, 2).SetValue<decimal>(item.Enero);
                    worksheet.Cell(currentRow, 3).SetValue<decimal>(item.Febrero);
                    worksheet.Cell(currentRow, 4).SetValue<decimal>(item.Marzo);
                    worksheet.Cell(currentRow, 5).SetValue<decimal>(item.Abril);
                    worksheet.Cell(currentRow, 6).SetValue<decimal>(item.Mayo);
                    worksheet.Cell(currentRow, 7).SetValue<decimal>(item.Junio);
                    worksheet.Cell(currentRow, 8).SetValue<decimal>(item.Julio);
                    worksheet.Cell(currentRow, 9).SetValue<decimal>(item.Agosto);
                    worksheet.Cell(currentRow, 10).SetValue<decimal>(item.Setiembre);
                    worksheet.Cell(currentRow, 11).SetValue<decimal>(item.Octubre);
                    worksheet.Cell(currentRow, 12).SetValue<decimal>(item.Noviembre);
                    worksheet.Cell(currentRow, 13).SetValue<decimal>(item.Diciembre);
                    worksheet.Cell(currentRow, 14).SetValue<decimal>(model.TotalDependencia(item.C_CodDependencia));

                    currentRow++;
                }

                worksheet.Cell(currentRow, 1).Value = "Total (S/.)";
                worksheet.Cell(currentRow, 2).SetValue<decimal>(model.TotalEnero);
                worksheet.Cell(currentRow, 3).SetValue<decimal>(model.TotalFebrero);
                worksheet.Cell(currentRow, 4).SetValue<decimal>(model.TotalMarzo);
                worksheet.Cell(currentRow, 5).SetValue<decimal>(model.TotalAbril);
                worksheet.Cell(currentRow, 6).SetValue<decimal>(model.TotalMayo);
                worksheet.Cell(currentRow, 7).SetValue<decimal>(model.TotalJunio);
                worksheet.Cell(currentRow, 8).SetValue<decimal>(model.TotalJulio);
                worksheet.Cell(currentRow, 9).SetValue<decimal>(model.TotalAgosto);
                worksheet.Cell(currentRow, 10).SetValue<decimal>(model.TotalSetiembre);
                worksheet.Cell(currentRow, 11).SetValue<decimal>(model.TotalOctubre);
                worksheet.Cell(currentRow, 12).SetValue<decimal>(model.TotalNoviembre);
                worksheet.Cell(currentRow, 13).SetValue<decimal>(model.TotalDiciembre);
                worksheet.Cell(currentRow, 14).SetValue<decimal>(model.TotalGeneral);

                worksheet.Range(worksheet.Cell(inicial, 2), worksheet.Cell(currentRow, 15)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);

                    var content = stream.ToArray();

                    string nombreArchivo = "Resumen Dependencias " + tipoEstudio.ToString() + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", nombreArchivo);
                }
            }
        }
    }
}
