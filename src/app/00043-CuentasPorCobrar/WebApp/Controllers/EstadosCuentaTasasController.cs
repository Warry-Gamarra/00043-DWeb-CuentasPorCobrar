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
    [Authorize(Roles = "Administrador, Consulta, Tesorería")]
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
                model.resultado = tasaService.listarPagoTasas(model.entidadFinanciera, model.idCtaDeposito, model.codOperacion, model.fechaInicio, model.fechaFin,
                    model.codDepositante);
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
                model.resultado = tasaService.listarPagoTasas(model.entidadFinanciera, model.idCtaDeposito, model.codOperacion, model.fechaInicio, model.fechaFin,
                    model.codDepositante);
            }
            else
            {
                return RedirectToAction("Consulta", "EstadosCuentaTasas");
            }

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("PagoTasas");
                var currentRow = 1;

                worksheet.Column("A").Width = 15;
                worksheet.Column("B").Width = 20;
                worksheet.Column("C").Width = 35;
                worksheet.Column("D").Width = 15;
                worksheet.Column("E").Width = 35;
                worksheet.Columns("F:G").Width = 15;
                worksheet.Column("H").Width = 30;
                worksheet.Columns("I:J").Width = 15;

                worksheet.Cell(currentRow, 1).Value = "Cod.Operación";
                worksheet.Cell(currentRow, 2).Value = "Cod.Depositante";
                worksheet.Cell(currentRow, 3).Value = "Nom.Depositante";
                worksheet.Cell(currentRow, 4).Value = "Tasa";
                worksheet.Cell(currentRow, 5).Value = "Concepto";
                worksheet.Cell(currentRow, 6).Value = "Fec.Pago";
                worksheet.Cell(currentRow, 7).Value = "Monto Tasa";
                worksheet.Cell(currentRow, 8).Value = "Banco";
                worksheet.Cell(currentRow, 9).Value = "Cta.Deposito";
                worksheet.Cell(currentRow, 10).Value = "Monto Pagado";
                
                foreach (var item in model.resultado)
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodTasa);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_ConceptoPagoDesc);
                    worksheet.Cell(currentRow, 6).SetValue<DateTime>(item.D_FecPago);
                    worksheet.Cell(currentRow, 7).SetValue<decimal?>(item.M_Monto);
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.T_EntidadDesc);
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.C_NumeroCuenta);
                    worksheet.Cell(currentRow, 10).SetValue<decimal>(item.I_MontoTotalPagado);
                }

                worksheet.Columns("G").Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;
                worksheet.Columns("J").Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

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