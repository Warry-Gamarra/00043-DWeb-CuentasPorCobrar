using Domain.Helpers;
using Ionic.Zip;
using Microsoft.Reporting.WebForms;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.DataSets;
using WebApp.Models.Facades;
using WebApp.Models.ReportModels;
using WebApp.ViewModels;
using WebGrease.Css.Extensions;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    public class ReportesController : Controller
    {
        IObligacionServiceFacade obligacionServiceFacade;
        IAlumnosClientFacade alumnosClientFacade;
        PagosModel pagosModel;
        public ITasaServiceFacade _tasaService;

        public ReportesController()
        {
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            pagosModel = new PagosModel();
            _tasaService = new TasaServiceFacade();
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.CONTABILIDAD + ", " + RoleNames.TESORERIA)]
        [Route("obligaciones/reporte-obligacion-alumno")]
        public ActionResult ReporteObligaciones(int anio, int periodo, string codalu, string codrc)
        {
            string docType = "pdf";

            string reportName = "RptObligacionesPorPeriodo";

            string dataSet1 = "CabeceraObligacionAlumnoDSet";

            string dataSet2 = "DetalleObligacionAlumnoDSet";

            var alumnoObligacionAlumnoDSet = new List<CabObligacionAlumnoRptModel>();

            var detalleObligacionAlumnoDSet = new List<DetObligacionAlumnoRptModel>();

            var alumno = alumnosClientFacade.GetByID(codrc, codalu);

            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago(anio, periodo, codalu, codrc);

            var detalle_pago = obligacionServiceFacade.Obtener_DetallePago(anio, periodo, codalu, codrc);

            cuotas_pago.ForEach(c => {
                alumnoObligacionAlumnoDSet.Add(new CabObligacionAlumnoRptModel()
                {
                    T_NroOrden = c.T_NroOrden,
                    I_MontoOblig = c.I_MontoOblig ?? 0,
                    T_MontoOblig = c.T_MontoOblig,
                    T_FecVencto = c.T_FecVencto,
                    B_Pagado = c.B_Pagado,
                    T_Pagado = c.T_Pagado,
                    I_MontoPagadoActual = c.I_MontoPagadoActual,
                    T_MontoPagadoActual = c.T_MontoPagadoActual
                });
            });

            detalle_pago.ForEach(d =>
            {
                d.I_NroOrden = cuotas_pago.Find(c => c.I_ObligacionAluID == d.I_ObligacionAluID).I_NroOrden;

                var pago = pagosModel.ObtenerPagoObligacionDetalle(d.I_ObligacionAluDetID).OrderByDescending(p => p.D_FecPago).FirstOrDefault();
                d.T_NroRecibo = (pago == null) ? "" : pago.C_CodOperacion;
                d.D_FecPago = (pago == null) ? "/ /" : (pago.D_FecPago.HasValue ? pago.D_FecPago.Value.ToString(FormatosDateTime.BASIC_DATE) : "/ /");
                d.T_LugarPago = (pago == null) ? "" : pago.T_LugarPago;

                if (!d.B_Mora)
                {
                    detalleObligacionAlumnoDSet.Add(new DetObligacionAlumnoRptModel()
                    {
                        T_ConceptoDesc = d.T_ConceptoDesc,
                        T_NroOrden = d.T_NroOrden,
                        T_ProcesoDesc = d.T_ProcesoDesc,
                        I_Monto = d.I_Monto ?? 0,
                        T_Monto = d.T_Monto,
                        T_FecVencto = d.T_FecVencto,
                        T_TipoObligacion = d.T_TipoObligacion,
                        T_Pagado = d.T_Pagado,
                        T_NroRecibo = d.T_NroRecibo,
                        T_FecPago = d.D_FecPago,
                        T_LugarPago = d.T_LugarPago
                    });
                }
            });
            
            var reportDataSets = new Dictionary<string, Object>();

            reportDataSets.Add(dataSet1, alumnoObligacionAlumnoDSet);

            reportDataSets.Add(dataSet2, detalleObligacionAlumnoDSet);

            var parameterList = new List<ReportParameter>();

            parameterList.Add(new ReportParameter("C_CodAlu", alumno.C_CodAlu));

            parameterList.Add(new ReportParameter("T_Alumno", String.Format("{0} {1} {2}", alumno.T_ApePaterno, alumno.T_ApeMaterno, alumno.T_Nombre)));

            parameterList.Add(new ReportParameter("T_FacDesc", alumno.T_FacDesc));

            parameterList.Add(new ReportParameter("T_EscDesc", alumno.T_EscDesc));

            parameterList.Add(new ReportParameter("T_DenomProg", alumno.T_DenomProg));

            var periodoDesc = (cuotas_pago != null && cuotas_pago.Count > 0) ? (cuotas_pago.First().I_Anio.ToString() + "-" + cuotas_pago.First().C_Periodo) : "";

            var totalGenerado = (cuotas_pago != null && cuotas_pago.Count > 0) ? cuotas_pago.Sum(x => x.I_MontoOblig ?? 0) : 0;

            var totalPagado = (cuotas_pago != null && cuotas_pago.Count > 0) ? cuotas_pago.Sum(x => x.I_MontoPagadoSinMora) : 0;

            var totalDeuda = totalGenerado - totalPagado;

            parameterList.Add(new ReportParameter("T_Periodo", periodoDesc));

            parameterList.Add(new ReportParameter("T_TotalGenerado", totalGenerado.ToString(FormatosDecimal.BASIC_DECIMAL)));

            parameterList.Add(new ReportParameter("T_TotalPagado", totalPagado.ToString(FormatosDecimal.BASIC_DECIMAL)));

            parameterList.Add(new ReportParameter("T_TotalDeuda", totalDeuda.ToString(FormatosDecimal.BASIC_DECIMAL)));

            var i = 1;

            foreach (var item in cuotas_pago)
            {
                var numeroCuota = "T_Cuota" + i.ToString();

                var seccionMontoObligacion = item.T_MontoOblig + (item.B_Pagado ? String.Format(" ({0})", item.T_Pagado) : "");

                parameterList.Add(new ReportParameter(numeroCuota, String.Format("{0}\n{1}\n{2}", item.T_FecVencto, seccionMontoObligacion, item.T_NroOrden)));
                
                i++;
            }

            for (int j = i; j <= 10; j++)
            {
                var numeroCuota = "T_Cuota" + i.ToString();

                parameterList.Add(new ReportParameter(numeroCuota, ""));
            }

            return ReportExport(docType, reportName, reportDataSets, parameterList);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("consulta/ingresos-de-obligaciones/constancia-pago-obligacion")]
        public ActionResult ImprimirConstanciaPagoObligacion(int id)
        {
            var pagoBanco = pagosModel.ObtenerPagoBanco(id);

            var listaConceptos = pagosModel.ObtenerPagosPorBoucher(pagoBanco.I_EntidadFinanID, pagoBanco.C_CodOperacion,
                pagoBanco.C_CodDepositante, pagoBanco.D_FecPago.Value);

            var listaConceptosModel = new List<PagoConstanciaModel>();

            listaConceptos.ForEach(x => {
                listaConceptosModel.Add(new PagoConstanciaModel() { 
                    pagoBancoID = x.I_PagoBancoID,
                    anioConstancia = x.I_AnioConstancia,
                    nroConstancia = x.I_NroConstancia
                });
            });

            var resultado = pagosModel.ObtenerNroConstancia(listaConceptosModel, WebSecurity.CurrentUserId);

            bool generarReporte = resultado.Item1;

            if (!pagoBanco.I_AnioConstancia.HasValue) { pagoBanco.I_AnioConstancia = resultado.Item2; }

            if (!pagoBanco.I_NroConstancia.HasValue) { pagoBanco.I_NroConstancia = resultado.Item3; }

            if (generarReporte)
            {
                string docType = "pdf";

                string reportName = "RptConstanciaPagoObligacion";

                string dataSet = "PagoObligacionDS";

                var pagoObligacionDSet = new List<PagoObligacionRptModel>();

                listaConceptos
                    .OrderBy(c => c.T_ProcesoDesc)
                    .OrderBy(c => c.D_FecVencto)
                    .ForEach(c => {
                        pagoObligacionDSet.Add(new PagoObligacionRptModel()
                        {
                            T_ConceptoPago = c.T_ProcesoDesc,
                            T_MontoPagado = c.T_MontoPago,
                            T_Mora = c.T_InteresMora,
                            T_TotalPagado = c.T_MontoPagoTotal
                        });
                    });

                var reportDataSets = new Dictionary<string, Object>();

                reportDataSets.Add(dataSet, pagoObligacionDSet);

                var parameterList = new List<ReportParameter>();

                parameterList.Add(new ReportParameter("T_NroConstancia", pagoBanco.T_Constancia));
                parameterList.Add(new ReportParameter("C_CodAlu", pagoBanco.T_CodDepositante));
                parameterList.Add(new ReportParameter("T_Alumno", pagoBanco.T_DatosDepositante));
                parameterList.Add(new ReportParameter("T_EntidadFinanciera", pagoBanco.T_EntidadDesc));
                parameterList.Add(new ReportParameter("T_NroLiquidacion", pagoBanco.C_CodOperacion));
                parameterList.Add(new ReportParameter("C_CodigoInterno", pagoBanco.C_CodigoInterno));
                parameterList.Add(new ReportParameter("T_FechaPago", pagoBanco.T_FecPago));
                parameterList.Add(new ReportParameter("T_TotalPagado", listaConceptos.Sum(x => x.I_MontoPagoTotal).ToString(FormatosDecimal.BASIC_DECIMAL)));

                return ReportExport(docType, reportName, reportDataSets, parameterList);
            }
            else
            {
                return RedirectToAction("ListarPagosBancoObligaciones", "EstadosCuenta");
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("consulta/ingresos-de-obligaciones/constancia-pago-tasa")]
        public ActionResult ImprimirConstanciaPagoTasa(int id)
        {
            string docType = "pdf";

            string reportName = "RptConstanciaPagoTasa";

            var pagoBanco = _tasaService.ObtenerPagoTasa(id);

            var listaConceptosModel = new List<PagoConstanciaModel>();

            listaConceptosModel.Add(new PagoConstanciaModel() {
                pagoBancoID = pagoBanco.I_PagoBancoID,
                anioConstancia = pagoBanco.I_AnioConstancia,
                nroConstancia = pagoBanco.I_NroConstancia
            });

            var resultado = pagosModel.ObtenerNroConstancia(listaConceptosModel, WebSecurity.CurrentUserId);

            bool generarReporte = resultado.Item1;

            if (!pagoBanco.I_AnioConstancia.HasValue) { pagoBanco.I_AnioConstancia = resultado.Item2; }

            if (!pagoBanco.I_NroConstancia.HasValue) { pagoBanco.I_NroConstancia = resultado.Item3; }

            if (generarReporte)
            {
                string dataSet = "PagoTasaDS";

                var pagoTasaDSet = new List<PagoTasaRptModel>();

                pagoTasaDSet.Add(new PagoTasaRptModel()
                {
                    T_ConceptoPago = pagoBanco.T_ConceptoPagoDesc,
                    T_Tasa = pagoBanco.C_CodTasa,
                    T_TotalPagado = pagoBanco.T_MontoTotalPagado
                });

                var reportDataSets = new Dictionary<string, Object>();

                reportDataSets.Add(dataSet, pagoTasaDSet);

                var parameterList = new List<ReportParameter>();

                parameterList.Add(new ReportParameter("T_NroConstancia", pagoBanco.T_Constancia));
                parameterList.Add(new ReportParameter("C_CodDepositante", pagoBanco.C_CodDepositante));
                parameterList.Add(new ReportParameter("T_NomDepositante", pagoBanco.T_NomDepositante.StartsWith("0") ? "-" : pagoBanco.T_NomDepositante));
                parameterList.Add(new ReportParameter("T_EntidadFinanciera", pagoBanco.T_EntidadDesc));
                parameterList.Add(new ReportParameter("T_NroLiquidacion", pagoBanco.C_CodOperacion));
                parameterList.Add(new ReportParameter("C_CodigoInterno", pagoBanco.C_CodigoInterno));
                parameterList.Add(new ReportParameter("T_FechaPago", pagoBanco.T_FecPago));

                return ReportExport(docType, reportName, reportDataSets, parameterList);
            }
            else
            {
                return RedirectToAction("Consulta", "EstadosCuentaTasa");
            }
        }

        private FileContentResult ReportExport(string docType, string reportName, Dictionary<string, Object> reportDataSets, IEnumerable<ReportParameter> parameters)
        {
            string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), reportName + ".rdlc");

            if (!System.IO.File.Exists(reportPath))
            {
                throw new FileNotFoundException();
            }

            var localReport = new LocalReport()
            {
                ReportPath = reportPath,
                EnableExternalImages = true
            };

            if (reportDataSets != null && reportDataSets.Count() > 0)
            {
                foreach (var item in reportDataSets)
                {
                    localReport.DataSources.Add(new ReportDataSource(item.Key, item.Value));
                }
            }

            if (parameters != null && parameters.Count() > 0)
            {
                localReport.SetParameters(parameters);
            }

            string reportType = docType;
            string mimeType;
            string encoding;
            string fileNameExtension;

            Warning[] warnings;
            string[] streams;
            byte[] renderedBytes;

            renderedBytes = localReport.Render(reportType, null, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);

            string extension = (docType == "excel") ? "xls" : "pdf";

            return File(renderedBytes, mimeType);
        }

        //private FileContentResult ReportExport(string docType, string reportName, Dictionary<string, Object> reportDataSets, IEnumerable<ReportParameter> parameters)
        //{
        //    string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), reportName + ".rdlc");

        //    if (!System.IO.File.Exists(reportPath))
        //    {
        //        throw new FileNotFoundException();
        //    }

        //    var localReport = new LocalReport()
        //    {
        //        ReportPath = reportPath,
        //        EnableExternalImages = true
        //    };

        //    if (reportDataSets != null && reportDataSets.Count() > 0)
        //    {
        //        foreach (var item in reportDataSets)
        //        {
        //            localReport.DataSources.Add(new ReportDataSource(item.Key, item.Value));
        //        }
        //    }

        //    if (parameters != null && parameters.Count() > 0)
        //    {
        //        localReport.SetParameters(parameters);
        //    }

        //    string reportType = docType;
        //    string mimeType;
        //    string encoding;
        //    string fileNameExtension;

        //    Warning[] warnings;
        //    string[] streams;
        //    byte[] renderedBytes;

        //    renderedBytes = localReport.Render(reportType, null, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);

        //    string extension = (docType == "excel") ? "xls" : "pdf";

        //    //Nuevo
        //    var stream = new MemoryStream(renderedBytes);

        //    using (ZipFile zip = new ZipFile())
        //    {
        //        //foreach (var smdId in reports)
        //        //{
        //            string fileName = $"smdReport_{DateTime.Now.ToString()}" + extension;

        //        using (var report = stream)
        //            {
        //                // convert stream to archive
        //                zip.AddEntry($"{fileName}", report.ToArray());
        //            }
        //        //}

        //        MemoryStream output = new MemoryStream();

        //        zip.Save(output);

        //        return File(output.ToArray(), "application/zip", "sample.zip");
        //    }
        //}
    }
}