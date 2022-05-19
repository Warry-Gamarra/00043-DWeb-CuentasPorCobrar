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
            string docType = "pdf";

            string fileName = "Relación de obligaciones";

            string dataSetName = "ObligacionAlumnoDSet";

            string rptName = "RptObligacionesPorPeriodo";

            var dataSet = new List<ObligacionAlumnoRptModel>();

            string codRc = "M98";
            string codAlu = "2014319842";
            int anio = 2021;
            int periodo = 20;

            var alumno = alumnosClientFacade.GetByID(codRc, codAlu);

            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago(anio, periodo, codAlu, codRc);

            var detalle_pago = obligacionServiceFacade.Obtener_DetallePago(anio, periodo, codAlu, codRc);

            detalle_pago.ForEach(d =>
            {
                d.I_NroOrden = cuotas_pago.Find(c => c.I_ObligacionAluID == d.I_ObligacionAluID).I_NroOrden;
                var pago = pagosModel.ObtenerPagoObligacionDetalle(d.I_ObligacionAluDetID).OrderByDescending(p => p.D_FecPago).FirstOrDefault();
                d.T_NroRecibo = (pago == null) ? "" : pago.C_CodOperacion;
                d.D_FecPago = (pago == null) ? "/ /" : (pago.D_FecPago.HasValue ? pago.D_FecPago.Value.ToString(FormatosDateTime.BASIC_DATE) : "/ /");
                d.T_LugarPago = (pago == null) ? "" : pago.T_LugarPago;

                dataSet.Add(new ObligacionAlumnoRptModel()
                {
                    T_ConceptoDesc = d.T_ConceptoDesc,
                    T_NroOrden = d.T_NroOrden,
                    T_ProcesoDesc = d.T_ProcesoDesc,
                    I_Monto = d.T_Monto,
                    T_FecVencto = d.T_FecVencto,
                    T_TipoObligacion = d.T_TipoObligacion,
                    T_Pagado = d.T_Pagado,
                    T_NroRecibo = d.T_NroRecibo,
                    T_FecPago = d.D_FecPago,
                    T_LugarPago = d.T_LugarPago
                });
            });


            TempData["dataSet"] = dataSet;

            var parameterList = new List<ReportParameter>();

            parameterList.Add(new ReportParameter("C_CodAlu", alumno.C_CodAlu));

            parameterList.Add(new ReportParameter("T_Alumno", String.Format("{0} {1} {2}", alumno.T_ApePaterno, alumno.T_ApeMaterno, alumno.T_Nombre)));

            parameterList.Add(new ReportParameter("T_FacDesc", ""));

            parameterList.Add(new ReportParameter("T_EscDesc", ""));

            parameterList.Add(new ReportParameter("T_DenomProg", alumno.T_DenomProg));

            parameterList.Add(new ReportParameter("T_Periodo", ""));

            TempData["parameters"] = parameterList;

            return RedirectToAction("ReportExport", "Reportes", new { docType = docType, dataSetName = dataSetName, rptName = rptName, fileName = fileName });
        }

        public ActionResult ReportExport(string docType, string dataSetName, string rptName, string fileName, string subRptName)
        {
            LocalReport lr = new LocalReport();

            string path = Path.Combine(Server.MapPath("~/ReportesRDLC"), rptName + ".rdlc");

            if (System.IO.File.Exists(path))
            {
                lr.ReportPath = path;
            }
            else
            {
                return new HttpNotFoundResult();
            }

            var rptDataSet = TempData["dataSet"];

            var rd = new ReportDataSource(dataSetName, rptDataSet);

            var parameters = TempData["parameters"] as List<ReportParameter>;

            lr.EnableExternalImages = true;
            
            lr.DataSources.Add(rd);

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

            return File(renderedBytes, mimeType, fileName + "." + extension);
        }
    }
}