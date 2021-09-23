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
    [Authorize(Roles = "Administrador, Consulta")]
    public class EstadosCuentaController : Controller
    {
        IReportePregradoServiceFacade reportePregradoServiceFacade;
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IGeneralServiceFacade generalServiceFacade;
        SelectModel selectModels;
        PagosModel pagoModel;

        public EstadosCuentaController()
        {
            reportePregradoServiceFacade = new ReportePregradoServiceFacade();
            reportePosgradoServiceFacade = new ReportePosgradoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
            generalServiceFacade = new GeneralServiceFacade();
            selectModels = new SelectModel();
            pagoModel = new PagosModel();
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

            ViewBag.TipoReportes = generalServiceFacade.Listar_TipoReporteObligaciones();

            if (model.tipoEstudio == TipoEstudio.Pregrado)
            {
                ObtenerReportePregradoObligacion(model);

                ViewBag.Title = "Reportes de Pago de Obligaciones de Pregrado";
            }

            if (model.tipoEstudio == TipoEstudio.Posgrado)
            {
                ObtenerReportePosgradoObligacion(model);

                ViewBag.Title = "Reportes de Pago de Obligaciones de Posgrado";
            }

            return View(model);
        }

        [Route("consultas/reporte-pago-de-obligaciones/descarga")]
        public ActionResult DescargaReportesPagoObligaciones(ReportePagosObligacionesViewModel model)
        {
            Tuple<string, XLWorkbook> reporte;

            switch (model.tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    reporte = ObtenerReporteExcelPregradoObligacion(model);
                    break;

                case TipoEstudio.Posgrado:
                    reporte = ObtenerExcelReportePosgradoObligacion(model);
                    break;

                default:
                    reporte = null;
                    break;
            }

            using (var stream = new MemoryStream())
            {
                reporte.Item2.SaveAs(stream);

                var content = stream.ToArray();

                return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", reporte.Item1);
            }
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

        [Route("consultas/resumen-anual-obligaciones-por-clasificadores/descarga")]
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
                worksheet.Cell(currentRow, 15).Value = "Total (S/)";

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

                worksheet.Cell(currentRow, 2).Value = "Total (S/)";
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

        [Route("consultas/resumen-anual-obligaciones-por-dependencias/descarga")]
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
                worksheet.Cell(currentRow, 14).Value = "Total (S/)";

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

                worksheet.Cell(currentRow, 1).Value = "Total (S/)";
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

        private void ObtenerReportePregradoObligacion(ReportePagosObligacionesViewModel model)
        {
            if (model.tipoReporte == Reportes.REPORTE_GENERAL)
            {
                model.reportePagosPorFacultadViewModel = reportePregradoServiceFacade.ReportePagosPorFacultad(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);
            }

            if (model.tipoReporte == Reportes.REPORTE_CONCEPTO)
            {
                if (String.IsNullOrEmpty(model.dependencia))
                {
                    model.reportePagosPorConceptoViewModel = reportePregradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);
                }
                else
                {
                    model.reporteConceptosPorUnaFacultadViewModel = reportePregradoServiceFacade.ReporteConceptosPorUnaFacultad(model.dependencia, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);
                }
            }
        }

        private Tuple<string, XLWorkbook> ObtenerReporteExcelPregradoObligacion(ReportePagosObligacionesViewModel model)
        {
            string nombreArchivo = "";
            XLWorkbook workbook = null;

            if (model.tipoReporte == Reportes.REPORTE_GENERAL)
            {
                nombreArchivo = "Reporte Pregrado General" + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                workbook  = ReporteExcelPagosPorFacultad(
                    reportePregradoServiceFacade.ReportePagosPorFacultad(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera));
            }

            if (model.tipoReporte == Reportes.REPORTE_CONCEPTO)
            {
                if (String.IsNullOrEmpty(model.dependencia))
                {
                    nombreArchivo = "Reporte Pregrado por Conceptos" + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                    workbook = ReporteExcelPagosPorConcepto(
                        reportePregradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera));
                }
                else
                {
                    nombreArchivo = "Reporte Pregrado por Conceptos" + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                    workbook = ReporteExcelConceptosPorUnaFacultad(
                        reportePregradoServiceFacade.ReporteConceptosPorUnaFacultad(model.dependencia, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera));
                }
            }

            return new Tuple<string, XLWorkbook>(nombreArchivo, workbook);
        }

        private XLWorkbook ReporteExcelPagosPorFacultad(ReportePagosPorFacultadViewModel reporte)
        {
            var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("ReportePregrado");

            worksheet.Column("A").Width = 14;

            worksheet.Column("B").Width = 60;

            worksheet.Column("C").Width = 14;

            var titleCell = worksheet.Cell(1, 1);

            titleCell.Value = reporte.Titulo.ToUpper();

            titleCell.RichText.SetBold(true);

            titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(titleCell, worksheet.Cell(1, 3)).Merge(true);

            var subTitleCell = worksheet.Cell(2, 1);

            subTitleCell.Value = reporte.SubTitulo.ToUpper();

            subTitleCell.RichText.SetBold(true);

            subTitleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(subTitleCell, worksheet.Cell(2, 3)).Merge(true);

            var bankNameCell = worksheet.Cell(4, 1);

            bankNameCell.Value = String.IsNullOrEmpty(reporte.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + reporte.nombreEntidadFinanc;

            var dateCell = worksheet.Cell(4, 3);

            dateCell.Value = "Fecha consulta: " + reporte.FechaActual;

            dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var timeCell = worksheet.Cell(5, 3);

            timeCell.Value = "Hora consulta: " + reporte.HoraActual;

            timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var currentRow = 7;

            worksheet.Cell(currentRow, 1).Value = "Código";
            worksheet.Cell(currentRow, 2).Value = "Facultad";
            worksheet.Cell(currentRow, 3).Value = "Monto (S/)";

            currentRow++;

            var inicial = currentRow;

            foreach (var item in reporte.listaPagos)
            {
                worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodFac);
                worksheet.Cell(currentRow, 2).SetValue<string>(item.T_FacDesc);
                worksheet.Cell(currentRow, 3).SetValue<decimal>(item.I_MontoTotal);

                currentRow++;
            }
            
            worksheet.Cell(currentRow, 2).Value = "Total (S/)";
            worksheet.Cell(currentRow, 3).SetValue<decimal>(reporte.MontoTotal);
            
            worksheet.Range(worksheet.Cell(inicial, 3), worksheet.Cell(currentRow, 3)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

            return workbook;
        }

        private XLWorkbook ReporteExcelPagosPorConcepto(ReportePagosPorConceptoViewModel reporte)
        {
            var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("ReportePregrado");

            worksheet.Column("A").Width = 14;

            worksheet.Column("B").Width = 60;

            worksheet.Column("C").Width = 14;

            var titleCell = worksheet.Cell(1, 1);

            titleCell.Value = reporte.Titulo.ToUpper();

            titleCell.RichText.SetBold(true);

            titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(titleCell, worksheet.Cell(1, 3)).Merge(true);

            var subTitleCell = worksheet.Cell(2, 1);

            subTitleCell.Value = reporte.SubTitulo.ToUpper();

            subTitleCell.RichText.SetBold(true);

            subTitleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(subTitleCell, worksheet.Cell(2, 3)).Merge(true);

            var bankNameCell = worksheet.Cell(4, 1);

            bankNameCell.Value = String.IsNullOrEmpty(reporte.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + reporte.nombreEntidadFinanc;

            var dateCell = worksheet.Cell(4, 3);

            dateCell.Value = "Fecha consulta: " + reporte.FechaActual;

            dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var timeCell = worksheet.Cell(5, 3);

            timeCell.Value = "Hora consulta: " + reporte.HoraActual;

            timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var currentRow = 7;

            worksheet.Cell(currentRow, 1).Value = "Clasificador";
            worksheet.Cell(currentRow, 2).Value = "Concepto";
            worksheet.Cell(currentRow, 3).Value = "Monto (S/)";

            currentRow++;

            var inicial = currentRow;

            foreach (var item in reporte.listaPagos)
            {
                worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodClasificador);
                worksheet.Cell(currentRow, 2).SetValue<string>(item.T_ConceptoPagoDesc);
                worksheet.Cell(currentRow, 3).SetValue<decimal>(item.I_MontoTotal);

                currentRow++;
            }

            worksheet.Cell(currentRow, 2).Value = "Total (S/)";
            worksheet.Cell(currentRow, 3).SetValue<decimal>(reporte.MontoTotal);

            worksheet.Range(worksheet.Cell(inicial, 3), worksheet.Cell(currentRow, 3)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

            return workbook;
        }

        private XLWorkbook ReporteExcelConceptosPorUnaFacultad(ReporteConceptosPorUnaFacultadViewModel reporte)
        {
            var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("ReportePregrado");

            worksheet.Column("A").Width = 60;

            worksheet.Column("B").Width = 14;

            worksheet.Column("C").Width = 14;

            worksheet.Column("D").Width = 14;

            var titleCell = worksheet.Cell(1, 1);

            titleCell.Value = reporte.Titulo.ToUpper();

            titleCell.RichText.SetBold(true);

            titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(titleCell, worksheet.Cell(1, 4)).Merge(true);

            var subTitleCell = worksheet.Cell(2, 1);

            subTitleCell.Value = reporte.SubTitulo.ToUpper();

            subTitleCell.RichText.SetBold(true);

            subTitleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(subTitleCell, worksheet.Cell(2, 4)).Merge(true);

            var facultadCell = worksheet.Cell(4, 1);

            facultadCell.Value = "Facultad: " + reporte.Facultad.ToUpper();

            var dateCell = worksheet.Cell(4, 4);

            dateCell.Value = "Fecha consulta: " + reporte.FechaActual;

            dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var bankNameCell = worksheet.Cell(5, 1);

            bankNameCell.Value = String.IsNullOrEmpty(reporte.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + reporte.nombreEntidadFinanc;

            var timeCell = worksheet.Cell(5, 4);

            timeCell.Value = "Hora consulta: " + reporte.HoraActual;

            timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var currentRow = 7;

            worksheet.Cell(currentRow, 1).Value = "Concepto";
            worksheet.Cell(currentRow, 2).Value = "Clasificador";
            worksheet.Cell(currentRow, 3).Value = "Cantidad";
            worksheet.Cell(currentRow, 4).Value = "Monto (S/)";

            currentRow++;

            var inicial = currentRow;

            foreach (var item in reporte.listaPagos)
            {
                worksheet.Cell(currentRow, 1).SetValue<string>(item.T_ConceptoPagoDesc);
                worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodClasificador);
                worksheet.Cell(currentRow, 3).SetValue<int>(item.I_Cantidad);
                worksheet.Cell(currentRow, 4).SetValue<decimal>(item.I_MontoTotal);

                currentRow++;
            }

            worksheet.Cell(currentRow, 3).Value = "Total (S/)";
            worksheet.Cell(currentRow, 4).SetValue<decimal>(reporte.MontoTotal);

            worksheet.Range(worksheet.Cell(inicial, 4), worksheet.Cell(currentRow, 4)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

            return workbook;
        }

        private void ObtenerReportePosgradoObligacion(ReportePagosObligacionesViewModel model)
        {
            if (model.tipoReporte == Reportes.REPORTE_GENERAL)
            {
                model.reportePagosPorGradoViewModel = reportePosgradoServiceFacade.ReportePagosPorGrado(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);
            }

            if (model.tipoReporte == Reportes.REPORTE_CONCEPTO)
            {
                if (String.IsNullOrEmpty(model.dependencia))
                {
                    model.reportePagosPorConceptoPosgradoViewModel = reportePosgradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);
                }
                else
                {
                    model.reporteConceptosPorGradoViewModel = reportePosgradoServiceFacade.ReporteConceptosPorGrado(model.dependencia, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera);
                }
            }
        }

        private Tuple<string, XLWorkbook> ObtenerExcelReportePosgradoObligacion(ReportePagosObligacionesViewModel model)
        {
            string nombreArchivo = "";
            XLWorkbook workbook = null;

            if (model.tipoReporte == Reportes.REPORTE_GENERAL)
            {
                nombreArchivo = "Reporte Posgrado General" + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                workbook = ReporteExcelPagosPorGrado(
                    reportePosgradoServiceFacade.ReportePagosPorGrado(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera));
            }

            if (model.tipoReporte == Reportes.REPORTE_CONCEPTO)
            {
                if (String.IsNullOrEmpty(model.dependencia))
                {
                    nombreArchivo = "Reporte Posgrado por Conceptos" + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                    workbook = ReporteExcelPagosPorConceptoPosgrado(
                        reportePosgradoServiceFacade.ReportePagosPorConcepto(model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera));
                }
                else
                {
                    nombreArchivo = "Reporte Posgrado por Conceptos" + " al " + DateTime.Now.ToString(FormatosDateTime.BASIC_DATE2) + ".xlsx";

                    workbook = ReporteExcelConceptosPorGrado(
                        reportePosgradoServiceFacade.ReporteConceptosPorGrado(model.dependencia, model.fechaInicio.Value, model.fechaFin.Value, model.idEntidadFinanciera));
                }
            }

            return new Tuple<string, XLWorkbook>(nombreArchivo, workbook);
        }

        private XLWorkbook ReporteExcelPagosPorGrado(ReportePagosPorGradoViewModel reporte)
        {
            var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("ReportePosgrado");

            worksheet.Column("A").Width = 14;

            worksheet.Column("B").Width = 60;

            worksheet.Column("C").Width = 14;

            var titleCell = worksheet.Cell(1, 1);

            titleCell.Value = reporte.Titulo.ToUpper();

            titleCell.RichText.SetBold(true);

            titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(titleCell, worksheet.Cell(1, 3)).Merge(true);

            var subTitleCell = worksheet.Cell(2, 1);

            subTitleCell.Value = reporte.SubTitulo.ToUpper();

            subTitleCell.RichText.SetBold(true);

            subTitleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(subTitleCell, worksheet.Cell(2, 3)).Merge(true);

            var bankNameCell = worksheet.Cell(4, 1);

            bankNameCell.Value = String.IsNullOrEmpty(reporte.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + reporte.nombreEntidadFinanc;

            var dateCell = worksheet.Cell(4, 3);

            dateCell.Value = "Fecha consulta: " + reporte.FechaActual;

            dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var timeCell = worksheet.Cell(5, 3);

            timeCell.Value = "Hora consulta: " + reporte.HoraActual;

            timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var currentRow = 7;

            worksheet.Cell(currentRow, 1).Value = "Código";
            worksheet.Cell(currentRow, 2).Value = "Grado";
            worksheet.Cell(currentRow, 3).Value = "Monto (S/)";

            currentRow++;

            var inicial = currentRow;

            foreach (var item in reporte.listaPagos)
            {
                worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodEsc);
                worksheet.Cell(currentRow, 2).SetValue<string>(item.T_EscDesc);
                worksheet.Cell(currentRow, 3).SetValue<decimal>(item.I_MontoTotal);

                currentRow++;
            }

            worksheet.Cell(currentRow, 2).Value = "Total (S/)";
            worksheet.Cell(currentRow, 3).SetValue<decimal>(reporte.MontoTotal);

            worksheet.Range(worksheet.Cell(inicial, 3), worksheet.Cell(currentRow, 3)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

            return workbook;
        }

        private XLWorkbook ReporteExcelPagosPorConceptoPosgrado(ReportePagosPorConceptoPosgradoViewModel reporte)
        {
            var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("ReportePosgrado");

            worksheet.Column("A").Width = 14;

            worksheet.Column("B").Width = 60;

            worksheet.Column("C").Width = 14;

            var titleCell = worksheet.Cell(1, 1);

            titleCell.Value = reporte.Titulo.ToUpper();

            titleCell.RichText.SetBold(true);

            titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(titleCell, worksheet.Cell(1, 3)).Merge(true);

            var subTitleCell = worksheet.Cell(2, 1);

            subTitleCell.Value = reporte.SubTitulo.ToUpper();

            subTitleCell.RichText.SetBold(true);

            subTitleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(subTitleCell, worksheet.Cell(2, 3)).Merge(true);

            var bankNameCell = worksheet.Cell(4, 1);

            bankNameCell.Value = String.IsNullOrEmpty(reporte.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + reporte.nombreEntidadFinanc;

            var dateCell = worksheet.Cell(4, 3);

            dateCell.Value = "Fecha consulta: " + reporte.FechaActual;

            dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var timeCell = worksheet.Cell(5, 3);

            timeCell.Value = "Hora consulta: " + reporte.HoraActual;

            timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var currentRow = 7;

            worksheet.Cell(currentRow, 1).Value = "Clasificador";
            worksheet.Cell(currentRow, 2).Value = "Concepto";
            worksheet.Cell(currentRow, 3).Value = "Monto (S/)";

            currentRow++;

            var inicial = currentRow;

            foreach (var item in reporte.listaPagos)
            {
                worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodClasificador);
                worksheet.Cell(currentRow, 2).SetValue<string>(item.T_ConceptoPagoDesc);
                worksheet.Cell(currentRow, 3).SetValue<decimal>(item.I_MontoTotal);

                currentRow++;
            }

            worksheet.Cell(currentRow, 2).Value = "Total (S/)";
            worksheet.Cell(currentRow, 3).SetValue<decimal>(reporte.MontoTotal);

            worksheet.Range(worksheet.Cell(inicial, 3), worksheet.Cell(currentRow, 3)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

            return workbook;
        }

        private XLWorkbook ReporteExcelConceptosPorGrado(ReporteConceptosPorGradoViewModel reporte)
        {
            var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("ReportePosgrado");

            worksheet.Column("A").Width = 60;

            worksheet.Column("B").Width = 14;

            worksheet.Column("C").Width = 14;

            worksheet.Column("D").Width = 14;

            var titleCell = worksheet.Cell(1, 1);

            titleCell.Value = reporte.Titulo.ToUpper();

            titleCell.RichText.SetBold(true);

            titleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(titleCell, worksheet.Cell(1, 4)).Merge(true);

            var subTitleCell = worksheet.Cell(2, 1);

            subTitleCell.Value = reporte.SubTitulo.ToUpper();

            subTitleCell.RichText.SetBold(true);

            subTitleCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            worksheet.Range(subTitleCell, worksheet.Cell(2, 4)).Merge(true);

            var gradoDescripCell = worksheet.Cell(4, 1);

            gradoDescripCell.Value = "Grado: " + reporte.Grado.ToUpper();

            var dateCell = worksheet.Cell(4, 4);

            dateCell.Value = "Fecha consulta: " + reporte.FechaActual;

            dateCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var bankNameCell = worksheet.Cell(5, 1);

            bankNameCell.Value = String.IsNullOrEmpty(reporte.nombreEntidadFinanc) ? "" : "Entidad Financiera: " + reporte.nombreEntidadFinanc;

            var timeCell = worksheet.Cell(5, 4);

            timeCell.Value = "Hora consulta: " + reporte.HoraActual;

            timeCell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

            var currentRow = 7;

            worksheet.Cell(currentRow, 1).Value = "Concepto";
            worksheet.Cell(currentRow, 2).Value = "Clasificador";
            worksheet.Cell(currentRow, 3).Value = "Cantidad";
            worksheet.Cell(currentRow, 4).Value = "Monto (S/)";

            currentRow++;

            var inicial = currentRow;

            foreach (var item in reporte.listaPagos)
            {
                worksheet.Cell(currentRow, 1).SetValue<string>(item.T_ConceptoPagoDesc);
                worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodClasificador);
                worksheet.Cell(currentRow, 3).SetValue<int>(item.I_Cantidad);
                worksheet.Cell(currentRow, 4).SetValue<decimal>(item.I_MontoTotal);

                currentRow++;
            }

            worksheet.Cell(currentRow, 3).Value = "Total (S/)";
            worksheet.Cell(currentRow, 4).SetValue<decimal>(reporte.MontoTotal);

            worksheet.Range(worksheet.Cell(inicial, 4), worksheet.Cell(currentRow, 4)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

            return workbook;
        }

        [Route("consulta/pagos-banco-obligaciones")]
        public ActionResult ListarPagosBancoObligaciones(ConsultaPagosBancoObligacionesViewModel model)
        {
            if (model.buscar)
            {
                model.resultado = pagoModel.ListarPagoBancoObligacion(model.idBanco, model.codOperacion, model.codAlumno,
                model.fechaInicio, model.fechaFin);
            }
            
            ViewBag.Title = "Pagos en Banco de Obligaciones";

            ViewBag.EntidadesFinancieras = selectModels.GetEntidadesFinancieras();

            return View(model);
        }

        [Route("consulta/pagos-banco-obligaciones/descarga")]
        public ActionResult ListarPagosBancoObligacionesDescargaExcel(ConsultaPagosBancoObligacionesViewModel model)
        {
            model.resultado = pagoModel.ListarPagoBancoObligacion(model.idBanco, model.codOperacion, model.codAlumno,
                model.fechaInicio, model.fechaFin);

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("PagosBanco");

                worksheet.Column("A").Width = 30;
                worksheet.Columns("B:D").Width  = 16;
                worksheet.Column("E").Width = 30;
                worksheet.Columns("F:I").Width = 16;
                worksheet.Column("J").Width = 30;

                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Banco";
                worksheet.Cell(currentRow, 2).Value = "Cta.Deposito";
                worksheet.Cell(currentRow, 3).Value = "Cod.Operación";
                worksheet.Cell(currentRow, 4).Value = "Cod.Depositante";
                worksheet.Cell(currentRow, 5).Value = "Depositante";
                worksheet.Cell(currentRow, 6).Value = "Fecha Pago";
                worksheet.Cell(currentRow, 7).Value = "Monto Pagado";
                worksheet.Cell(currentRow, 8).Value = "Lugar";
                worksheet.Cell(currentRow, 9).Value = "Fec.Reg.Sistema";
                worksheet.Cell(currentRow, 10).Value = "Observación";
                #endregion

                #region Body
                foreach (var item in model.resultado)
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.T_EntidadDesc);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_NumeroCuenta);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_DatosDepositante);
                    worksheet.Cell(currentRow, 6).SetValue<DateTime?>(item.D_FecPago);
                    worksheet.Cell(currentRow, 7).SetValue<decimal>(item.I_MontoPago);
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.T_LugarPago);
                    worksheet.Cell(currentRow, 9).SetValue<DateTime>(item.D_FecCre);
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.T_Observacion);
                }
                #endregion

                worksheet.Range(worksheet.Cell(2, 7), worksheet.Cell(currentRow, 7)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Consulta Pago de Obligaciones.xlsx");
                }
            }
        }
    }
}
