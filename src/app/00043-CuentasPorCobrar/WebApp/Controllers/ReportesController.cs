using DocumentFormat.OpenXml.Bibliography;
using Domain.Helpers;
using Ionic.Zip;
using Microsoft.Reporting.WebForms;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
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
            string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), "RptObligacionesPorPeriodo.rdlc");

            if (!System.IO.File.Exists(reportPath))
            {
                throw new FileNotFoundException();
            }

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

            var reporte = GenerarReporte(reportPath, reportDataSets, parameterList);

            return File(reporte.RenderedBytes, reporte.MimeType);
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
                string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), "RptConstanciaPagoObligacion.rdlc");

                if (!System.IO.File.Exists(reportPath))
                {
                    throw new FileNotFoundException();
                }

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

                var reporte = GenerarReporte(reportPath, reportDataSets, parameterList);

                return File(reporte.RenderedBytes, reporte.MimeType);
            }
            else
            {
                return RedirectToAction("ListarPagosBancoObligaciones", "EstadosCuenta");
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.CONTABILIDAD + ", " + RoleNames.TESORERIA)]
        [Route("consulta/ingresos-de-obligaciones/constancias-pago-obligacion")]
        public ActionResult DescargarConstanciaPagoObligaciones(ConsultaPagosBancoObligacionesViewModel model)
        {
            var listaGeneral = pagosModel.ListarPagoBancoObligacion(model);

            var listaPagos = listaGeneral.GroupBy(x => new { x.I_EntidadFinanID, x.C_CodOperacion, x.C_CodDepositante, x.T_FecPago });

            string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), "RptConstanciaPagoObligacion.rdlc"), dataSet = "PagoObligacionDS";

            if (!System.IO.File.Exists(reportPath))
            {
                throw new FileNotFoundException();
            }

            bool generarReporte;

            string pdfFileName, zipFileName;

            using (var zip = new ZipFile())
            {
                foreach (var item in listaPagos)
                {
                    var pagoCabecera = item.First();

                    var listaConceptosModel = new List<PagoConstanciaModel>();

                    item.ForEach(x => {
                        listaConceptosModel.Add(new PagoConstanciaModel()
                        {
                            pagoBancoID = x.I_PagoBancoID,
                            anioConstancia = x.I_AnioConstancia,
                            nroConstancia = x.I_NroConstancia
                        });
                    });

                    var resultado = pagosModel.ObtenerNroConstancia(listaConceptosModel, WebSecurity.CurrentUserId);

                    generarReporte = resultado.Item1;

                    if (!pagoCabecera.I_AnioConstancia.HasValue) { pagoCabecera.I_AnioConstancia = resultado.Item2; }

                    if (!pagoCabecera.I_NroConstancia.HasValue) { pagoCabecera.I_NroConstancia = resultado.Item3; }

                    if (generarReporte)
                    {
                        var pagoObligacionDSet = new List<PagoObligacionRptModel>();

                        item
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

                        parameterList.Add(new ReportParameter("T_NroConstancia", pagoCabecera.T_Constancia));
                        parameterList.Add(new ReportParameter("C_CodAlu", pagoCabecera.T_CodDepositante));
                        parameterList.Add(new ReportParameter("T_Alumno", pagoCabecera.T_DatosDepositante));
                        parameterList.Add(new ReportParameter("T_EntidadFinanciera", pagoCabecera.T_EntidadDesc));
                        parameterList.Add(new ReportParameter("T_NroLiquidacion", pagoCabecera.C_CodOperacion));
                        parameterList.Add(new ReportParameter("C_CodigoInterno", pagoCabecera.C_CodigoInterno));
                        parameterList.Add(new ReportParameter("T_FechaPago", pagoCabecera.T_FecPago));
                        parameterList.Add(new ReportParameter("T_TotalPagado", item.Sum(x => x.I_MontoPagoTotal).ToString(FormatosDecimal.BASIC_DECIMAL)));

                        var reporte = GenerarReporte(reportPath, reportDataSets, parameterList);

                        using (var stream = new MemoryStream(reporte.RenderedBytes))
                        {
                            pdfFileName = pagoCabecera.T_Constancia + ".pdf";

                            zip.AddEntry(pdfFileName, stream.ToArray());
                        }
                    }
                }

                zipFileName = DateTime.Now.ToString(FormatosDateTime.BASIC_DATETIME2) + ".zip";

                var output = new MemoryStream();

                zip.Save(output);

                return File(output.ToArray(), "application/zip", zipFileName);
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("consulta/ingresos-de-obligaciones/constancia-pago-tasa")]
        public ActionResult ImprimirConstanciaPagoTasa(int id)
        {
            string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), "RptConstanciaPagoTasa.rdlc");

            if (!System.IO.File.Exists(reportPath))
            {
                throw new FileNotFoundException();
            }

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

                var reporte = GenerarReporte(reportPath, reportDataSets, parameterList);

                return File(reporte.RenderedBytes, reporte.MimeType);
            }
            else
            {
                return RedirectToAction("Consulta", "EstadosCuentaTasas");
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.CONTABILIDAD + ", " + RoleNames.TESORERIA)]
        [Route("consulta/ingresos-de-obligaciones/constancias-pago-tasa")]
        public ActionResult DescargarConstanciaPagoTasas(ConsultaPagoTasasViewModel model)
        {
            var listaPagos = _tasaService.listarPagoTasas(model);

            string reportPath = Path.Combine(Server.MapPath("~/ReportesRDLC"), "RptConstanciaPagoTasa.rdlc"), dataSet = "PagoTasaDS";

            if (!System.IO.File.Exists(reportPath))
            {
                throw new FileNotFoundException();
            }

            bool generarReporte;

            string pdfFileName, zipFileName;

            using (var zip = new ZipFile())
            {
                foreach (var item in listaPagos)
                {
                    var listaConceptosModel = new List<PagoConstanciaModel>();

                    listaConceptosModel.Add(new PagoConstanciaModel()
                    {
                        pagoBancoID = item.I_PagoBancoID,
                        anioConstancia = item.I_AnioConstancia,
                        nroConstancia = item.I_NroConstancia
                    });

                    var resultado = pagosModel.ObtenerNroConstancia(listaConceptosModel, WebSecurity.CurrentUserId);

                    generarReporte = resultado.Item1;

                    if (!item.I_AnioConstancia.HasValue) { item.I_AnioConstancia = resultado.Item2; }

                    if (!item.I_NroConstancia.HasValue) { item.I_NroConstancia = resultado.Item3; }

                    if (generarReporte)
                    {
                        var pagoTasaDSet = new List<PagoTasaRptModel>();

                        pagoTasaDSet.Add(new PagoTasaRptModel()
                        {
                            T_ConceptoPago = item.T_ConceptoPagoDesc,
                            T_Tasa = item.C_CodTasa,
                            T_TotalPagado = item.T_MontoTotalPagado
                        });

                        var reportDataSets = new Dictionary<string, Object>();

                        reportDataSets.Add(dataSet, pagoTasaDSet);

                        var parameterList = new List<ReportParameter>();

                        parameterList.Add(new ReportParameter("T_NroConstancia", item.T_Constancia));
                        parameterList.Add(new ReportParameter("C_CodDepositante", item.C_CodDepositante));
                        parameterList.Add(new ReportParameter("T_NomDepositante", item.T_NomDepositante.StartsWith("0") ? "-" : item.T_NomDepositante));
                        parameterList.Add(new ReportParameter("T_EntidadFinanciera", item.T_EntidadDesc));
                        parameterList.Add(new ReportParameter("T_NroLiquidacion", item.C_CodOperacion));
                        parameterList.Add(new ReportParameter("C_CodigoInterno", item.C_CodigoInterno));
                        parameterList.Add(new ReportParameter("T_FechaPago", item.T_FecPago));

                        var reporte = GenerarReporte(reportPath, reportDataSets, parameterList);

                        using (var stream = new MemoryStream(reporte.RenderedBytes))
                        {
                            pdfFileName = item.T_Constancia + ".pdf";

                            zip.AddEntry(pdfFileName, stream.ToArray());
                        }
                    }
                }

                zipFileName = DateTime.Now.ToString(FormatosDateTime.BASIC_DATETIME2) + ".zip";

                var output = new MemoryStream();

                zip.Save(output);

                return File(output.ToArray(), "application/zip", zipFileName);
            }
        }

        private ReporteModel GenerarReporte(string reportPath, Dictionary<string, Object> reportDataSets, IEnumerable<ReportParameter> parameters)
        {
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
                localReport.SetParameters(parameters);//Esta línea causa lentitud
            }

            string mimeType;
            string encoding;
            string fileNameExtension;

            Warning[] warnings;
            string[] streams;
            byte[] renderedBytes = localReport.Render("pdf", null, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);

            return new ReporteModel(renderedBytes, mimeType, encoding, fileNameExtension);
        }
    }
}