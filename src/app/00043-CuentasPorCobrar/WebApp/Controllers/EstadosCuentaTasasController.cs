using ClosedXML.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
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
    [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.CONSULTA + ", " + RoleNames.TESORERIA)]
    public class EstadosCuentaTasasController : Controller
    {
        ITasaServiceFacade tasaService;
        SelectModel selectModels;
        
        public EstadosCuentaTasasController()
        {
            tasaService = new TasaServiceFacade();
            selectModels = new SelectModel();
        }
                
        [Route("consulta/tasas")]
        public ActionResult Consulta(ConsultaPagoTasasViewModel model)
        {
            ViewBag.Title = "Consulta de Pago de Tasas";

            if (model.buscar)
            {
                model.fechaHasta = String.IsNullOrEmpty(model.fechaHasta) ? model.fechaHasta : (model.fechaHasta + " 23:59:59");

                model.resultado = tasaService.listarPagoTasas(model);
            }

            ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", model.entidadFinanciera);

            ViewBag.CtaDeposito = new SelectList(
                model.entidadFinanciera.HasValue ? selectModels.GetCtasDeposito(model.entidadFinanciera.Value) : new List<SelectViewModel>(), "Value", "TextDisplay", model.idCtaDeposito);

            return View(model);
        }

        [Route("consulta/tasas/descarga")]
        public ActionResult DescargaExcelConsultaTasas(ConsultaPagoTasasViewModel model)
        {
            if (model.buscar)
            {
                model.fechaHasta = String.IsNullOrEmpty(model.fechaHasta) ? model.fechaHasta : (model.fechaHasta + " 23:59:59");

                model.resultado = tasaService.listarPagoTasas(model);
            }
            else
            {
                return RedirectToAction("Consulta", "EstadosCuentaTasas");
            }

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("PagoTasas");
                var currentRow = 1;

                worksheet.Columns("A:B").Width = 15;
                worksheet.Column("C").Width = 20;
                worksheet.Column("D").Width = 35;
                worksheet.Column("E").Width = 15;
                worksheet.Column("G").Width = 35;
                worksheet.Columns("G:H").Width = 15;
                worksheet.Column("I").Width = 30;
                worksheet.Columns("J:K").Width = 15;

                worksheet.Cell(currentRow, 1).Value = "Cod.Operación";
                worksheet.Cell(currentRow, 2).Value = "Cod.Interno (BCP)";
                worksheet.Cell(currentRow, 3).Value = "Cod.Depositante";
                worksheet.Cell(currentRow, 4).Value = "Nom.Depositante";
                worksheet.Cell(currentRow, 5).Value = "Tasa";
                worksheet.Cell(currentRow, 6).Value = "Concepto";
                worksheet.Cell(currentRow, 7).Value = "Fec.Pago";
                worksheet.Cell(currentRow, 8).Value = "Monto Tasa";
                worksheet.Cell(currentRow, 9).Value = "Banco";
                worksheet.Cell(currentRow, 10).Value = "Cta.Deposito";
                worksheet.Cell(currentRow, 11).Value = "Monto Pagado";
                
                foreach (var item in model.resultado)
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodigoInterno);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.C_CodTasa);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.T_ConceptoPagoDesc);
                    worksheet.Cell(currentRow, 7).SetValue<DateTime>(item.D_FecPago);
                    worksheet.Cell(currentRow, 8).SetValue<decimal?>(item.M_Monto);
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.T_EntidadDesc);
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.C_NumeroCuenta);
                    worksheet.Cell(currentRow, 11).SetValue<decimal>(item.I_MontoTotalPagado);
                }

                worksheet.Columns("H").Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;
                worksheet.Columns("K").Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Consulta Pago de Tasas.xlsx");
                }
            }
        }
    }
}