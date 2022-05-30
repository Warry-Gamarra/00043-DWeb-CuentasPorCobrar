using Domain.Helpers;
using Microsoft.Reporting.WebForms;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.Models.ReportModels;

namespace WebApp.Controllers
{
    public class ReportesController : Controller
    {
        IObligacionServiceFacade obligacionServiceFacade;
        IAlumnosClientFacade alumnosClientFacade;
        PagosModel pagosModel;

        public ReportesController()
        {
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            pagosModel = new PagosModel();
        }

        public ActionResult Index()
        {
            string codRc = "D07";
            string codAlu = "2015317031";
            int anio = 2021;
            int periodo = 20;


            string docType = "pdf";

            string outputFileName = "Relación de obligaciones";

            string dataSet1 = "CabeceraObligacionAlumnoDSet";

            string dataSet2 = "DetalleObligacionAlumnoDSet";

            string rptName = "RptObligacionesPorPeriodo";

            var alumnoObligacionAlumnoDSet = new List<CabObligacionAlumnoRptModel>();

            var detalleObligacionAlumnoDSet = new List<DetObligacionAlumnoRptModel>();

            var alumno = alumnosClientFacade.GetByID(codRc, codAlu);

            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago(anio, periodo, codAlu, codRc);

            var detalle_pago = obligacionServiceFacade.Obtener_DetallePago(anio, periodo, codAlu, codRc);

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
            
            var dataSets = new Dictionary<string, Object>();

            dataSets.Add(dataSet1, alumnoObligacionAlumnoDSet);

            dataSets.Add(dataSet2, detalleObligacionAlumnoDSet);

            TempData["dataSets"] = dataSets;

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

                var seccionMontoObligacion = "10,000.00" + (item.B_Pagado ? String.Format(" ({0})", item.T_Pagado) : "");

                parameterList.Add(new ReportParameter(numeroCuota, String.Format("{0}\n{1}\n{2}", item.T_FecVencto, seccionMontoObligacion, item.T_NroOrden)));
                
                i++;
            }

            for (int j = i; j <= 10; j++)
            {
                var numeroCuota = "T_Cuota" + i.ToString();

                parameterList.Add(new ReportParameter(numeroCuota, ""));
            }

            TempData["parameters"] = parameterList;

            return RedirectToAction("ReportExport", "Reportes", new { docType = docType, rptName = rptName, outputFileName = outputFileName });
        }

        public ActionResult ReportExport(string docType, string rptName, string outputFileName, string subRptName)
        {
            LocalReport lr = new LocalReport();

            lr.EnableExternalImages = true;

            string path = Path.Combine(Server.MapPath("~/ReportesRDLC"), rptName + ".rdlc");

            if (System.IO.File.Exists(path))
            {
                lr.ReportPath = path;
            }
            else
            {
                return new HttpNotFoundResult();
            }

            var rptDataSet = TempData["dataSets"] as Dictionary<string, Object>;

            foreach (var item in rptDataSet)
            {
                var rd = new ReportDataSource(item.Key, item.Value);

                lr.DataSources.Add(rd);
            }

            var parameters = TempData["parameters"] as List<ReportParameter>;

            lr.SetParameters(parameters);

            string reportType = docType;
            string mimeType;
            string encoding;
            string fileNameExtension;

            string deviceInfo = "";

            Warning[] warnings;
            string[] streams;
            byte[] renderedBytes;

            renderedBytes = lr.Render(reportType, deviceInfo, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);

            string extension = (docType == "excel") ? "xls" : "pdf";

            return File(renderedBytes, mimeType, outputFileName + "." + extension);
        }
    }
}