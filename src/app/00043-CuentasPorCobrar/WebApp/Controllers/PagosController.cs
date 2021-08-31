using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;
using Domain.Helpers;
using WebApp.Models;
using System.Globalization;
using WebApp.ViewModels;
using WebMatrix.WebData;
using ClosedXML.Excel;
using System.IO;
using System.Net;

namespace WebApp.Controllers
{
    [Authorize]
    public class PagosController : Controller
    {
        private readonly IGeneralServiceFacade generalServiceFacade;
        private readonly ICatalogoServiceFacade catalogoServiceFacade;
        private readonly IObligacionServiceFacade obligacionServiceFacade;
        private readonly IAlumnosClientFacade alumnosClientFacade;
        private readonly IProgramasClientFacade programasClientFacade;
        private readonly SelectModel selectModels;
        private readonly PagosModel pagosModel;
        private ITasaServiceFacade tasaService;
        private readonly EntidadRecaudadoraModel entidadRecaudadora;
        public readonly DependenciaModel _dependenciaModel;
        private readonly IMatriculaServiceFacade matriculaServiceFacade;

        public PagosController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
            selectModels = new SelectModel();
            pagosModel = new PagosModel();
            tasaService = new TasaServiceFacade();
            entidadRecaudadora = new EntidadRecaudadoraModel();
            _dependenciaModel = new DependenciaModel();
            matriculaServiceFacade = new MatriculaServiceFacade();
        }

        // GET: Pagos
        [Route("consultas/pagos-realizados/{anio}")]
        public ActionResult Index(int anio)
        {
            ViewBag.Title = "Pagos Registrados";

            var model = new List<DatosPagoViewModel>();
            return View(model);
        }


        [Route("operaciones/generar-archivos-pago")]
        public ActionResult ExportarDatosPago()
        {
            ViewBag.Title = "Generar archivos de pago";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

            ViewBag.Dependencias = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            ViewBag.EntidadesFinancieras = new List<SelectViewModel>();

            var model = new FiltroEnvioObligacionesViewModel()
            {
                I_Anio = DateTime.Now.Year,
                I_Periodo = 15,
                E_TipoEstudio = TipoEstudio.Pregrado,
                T_Dependencia = ""
            };

            return View(model);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("operaciones/generar-archivos-pago")]
        public ActionResult GenerarArchivosBancos(FiltroEnvioObligacionesViewModel model)
        {
            try
            {
                var transferenciaInformacion = TransferenciaInformacionFactory.Get(model.I_EntidadFinanciera);

                var memoryStream = transferenciaInformacion.GenerarInformacionObligaciones(model.I_Anio, model.I_Periodo, model.E_TipoEstudio, model.T_Dependencia);

                return File(memoryStream, "text/plain", transferenciaInformacion.NombreArchivoGenerado());
            }
            catch (Exception ex)
            {
                ViewBag.Title = "Generar archivos de pago";

                ViewBag.Anios = generalServiceFacade.Listar_Anios();

                ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

                ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

                ViewBag.Dependencias = programasClientFacade.GetFacultades(model.E_TipoEstudio);

                ViewBag.EntidadesFinancieras = new List<SelectViewModel>();

                ModelState.AddModelError("", ex.Message);

                return View("ExportarDatosPago", model);
            }
        }

        [Route("operaciones/cargar-pagos")]
        public ActionResult ImportarArchivosPago()
        {
            ViewBag.Title = "Cargar Pagos";
            return View();
        }

        private IEnumerable<SelectViewModel> ListaEntidadesFinancieras()
        {
            return selectModels.GetEntidadesFinancieras();
        }


        //[Route("operaciones/cargar-pagos/obligaciones")]
        public ActionResult ImportarPagoObligaciones()
        {
            ViewBag.Title = "Cargar pagos de obligaciones";

            var model = pagosModel.ListarArchivosCargados();

            return View(model);
        }

        [Route("operaciones/cargar-pagos/seleccionar-archivo/obligaciones")]
        public ActionResult SeleccionarArchivoObligaciones()
        {
            ViewBag.Tipo = "(OBLIGACIONES)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");

            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Obligacion };

            return PartialView("_SeleccionarArchivo", model);
        }

        //[Route("operaciones/cargar-pagos/tasas")]
        public ActionResult ImportarPagoTasas()
        {
            ViewBag.Title = "Cargar pagos de tasas";
            var model = new List<ArchivoImportadoViewModel>();
            return View(model);
        }


        [Route("operaciones/cargar-pagos/seleccionar-archivo/tasas")]
        public ActionResult SeleccionarArchivoTasas()
        {
            ViewBag.Tipo = "(TASAS)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");

            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Tasa }; 
            return PartialView("_SeleccionarArchivo", model);
        }


        [HttpPost]
        public ActionResult CargarArchivoPago(HttpPostedFileBase file, CargarArchivoViewModel model)
        {
            var result = pagosModel.CargarArchivoPagos(Server.MapPath("~/Upload/Pagos/"), file, model, WebSecurity.CurrentUserId);

            Session["PAGO_OBLIG_RESULT"] = result.ListaResultados;

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult DescargarResultadoPagoObligaciones()
        {
            if (Session["PAGO_OBLIG_RESULT"] == null)
                return RedirectToAction("ImportarPagoObligaciones", "Pagos");

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("PagoObligaciones");
                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "CodOperacion";
                worksheet.Cell(currentRow, 2).Value = "CodAlumno";
                worksheet.Cell(currentRow, 3).Value = "NomAlumno";
                worksheet.Cell(currentRow, 4).Value = "CuotaPago";
                worksheet.Cell(currentRow, 5).Value = "FechaVcto";
                worksheet.Cell(currentRow, 6).Value = "FechaPago";
                worksheet.Cell(currentRow, 7).Value = "Cantidad";
                worksheet.Cell(currentRow, 8).Value = "Moneda";
                worksheet.Cell(currentRow, 9).Value = "MontoPago";
                worksheet.Cell(currentRow, 10).Value = "InteresMoratorio";
                worksheet.Cell(currentRow, 11).Value = "LugarPago";
                worksheet.Cell(currentRow, 12).Value = "InforUnfv";
                worksheet.Cell(currentRow, 13).Value = "Estado";
                worksheet.Cell(currentRow, 14).Value = "Mensaje";

                #endregion

                #region Body
                var resultados = (IEnumerable<Domain.Entities.PagoObligacionObsEntity>)Session["PAGO_OBLIG_RESULT"];

                foreach (var item in resultados.OrderBy(x => x.D_FecPago))
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.T_ProcesoDesc);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.D_FecVencto.ToString(FormatosDateTime.BASIC_DATE));
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.D_FecPago.ToString(FormatosDateTime.BASIC_DATETIME));
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.I_Cantidad.ToString());
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.C_Moneda);
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.I_MontoPago.ToString("N2"));
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.I_InteresMora.ToString("N2"));
                    worksheet.Cell(currentRow, 11).SetValue<string>(item.T_LugarPago);
                    worksheet.Cell(currentRow, 12).SetValue<string>(item.T_InformacionAdicional);
                    worksheet.Cell(currentRow, 13).SetValue<string>(item.B_Success ? "Correcto" : "Observado");
                    worksheet.Cell(currentRow, 14).SetValue<string>(item.T_ErrorMessage);
                }
                #endregion

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de pagos.xlsx");
                }
            }
        }

        [HttpGet]
        public ActionResult RegistrarPagoObligacion()
        {

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");
            ViewBag.Especialidades = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");
            ViewBag.Proceso = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.CtaDeposito = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");

            ViewBag.Horas = new SelectList(generalServiceFacade.Listar_Horas(), "Value", "TextDisplay");
            ViewBag.Minutos = new SelectList(generalServiceFacade.Listar_Minutos(), "Value", "TextDisplay");

            var model = new PagoObligacionViewModel();

            return PartialView("_RegistrarPagoObligacion", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RegistrarPagoObligacion(PagoObligacionViewModel model)
        {
            ImportacionPagoResponse result = new ImportacionPagoResponse();

            if (ModelState.IsValid)
            {
                try
                {
                    int currentUserID = WebSecurity.CurrentUserId;

                    result = pagosModel.GrabarPagoObligacion(model, currentUserID);

                    if (!result.Success)
                    {
                        throw new Exception(result.Message);
                    }
                }
                catch (Exception ex)
                {
                    ResponseModel.Error(result, ex.Message);
                }
            }
            else
            {
                string details = "";

                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += error.ErrorMessage + " / ";
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos" + details);
            }

            return PartialView("_MsgRegistrarPagoObligacion", result);
        }

        [HttpGet]
        public ActionResult RegistrarPagoTasa()
        {
            ViewBag.Tasas = new SelectList(tasaService.listarTasas(), "Value", "TextDisplay");
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.CtaDeposito = new SelectList(new List<SelectViewModel>(), "Value", "TextDisplay");

            ViewBag.Horas = new SelectList(generalServiceFacade.Listar_Horas(), "Value", "TextDisplay");
            ViewBag.Minutos = new SelectList(generalServiceFacade.Listar_Minutos(), "Value", "TextDisplay");

            var model = new PagoTasaViewModel();

            return PartialView("_RegistrarPagoTasa", model);
        }

        [HttpPost]
        public ActionResult RegistrarPagoTasa(PagoTasaViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                try
                {
                    int currentUserID = WebSecurity.CurrentUserId;

                    model.fechaPago = model.fechaPago.Value.AddHours(model.horas).AddMinutes(model.minutos);

                    result = pagosModel.GrabarPagoTasa(model, currentUserID);

                    if (!result.Value)
                    {
                        throw new Exception(result.Message);
                    }
                }
                catch (Exception ex)
                {
                    ResponseModel.Error(result, ex.Message);
                }
            }
            else
            {
                string details = "";

                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += error.ErrorMessage + " / ";
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos" + details);
            }

            return PartialView("_MsgRegistrarPagoObligacion", result);
        }


        [Route("operaciones/actualizar-pagos")]
        public ActionResult Actualizar()
        {
            ViewBag.Title = "Actualizar información de pagos";

            var model = pagosModel.ListarPagosRegistrados();
            ViewBag.EntidadRecaudadora = new SelectList(entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.Dependencia = new SelectList(_dependenciaModel.Find(enabled: true), dataValueField: "DependenciaID", dataTextField: "DependDesc");

            return View(model);
        }

        [HttpPost]
        public ActionResult ObtenerPagosRegistrados(string txtFecDesde, string txtFecHasta, int cboEntRecauda, int cboDependencia)
        {
            ViewBag.Title = "Actualizar información de pagos";


            var model = pagosModel.ListarPagosRegistrados();
            ViewBag.EntidadRecaudadora = new SelectList(entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.Dependencia = new SelectList(_dependenciaModel.Find(enabled: true), dataValueField: "DependenciaID", dataTextField: "DependDesc");

            return View(model);
        }


        [Route("operaciones/pagos/{id}/ver-detalle")]
        public ActionResult Detalle(int id)
        {
            ViewBag.Title = "Detalles del pago";

            var model = pagosModel.ObtenerDatosPago(id);

            return PartialView("_DetallesPago", model);
        }

        [Route("operaciones/pagos/{id}/registrar-nro-siaf")]
        public ActionResult RegistrarSiaf(int id)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var model = pagosModel.ObtenerDatosPago(id);

            return PartialView("_RegistrarSiaf", model);
        }

        [HttpPost]
        public ActionResult RegistrarSiafLote(int[] pagosId, int nroSiaf)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var result = pagosModel.GrabarNroSiafPago(pagosId, nroSiaf, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);

        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RegistrarSiaf(DatosPagoViewModel model)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var result = new Response();

            if (ModelState.IsValid)
            {
                result = pagosModel.GrabarNroSiafPago(model, WebSecurity.CurrentUserId);
            }
            else
            {
                string details = "";

                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += error.ErrorMessage + " / ";
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos" + details);
            }
            return PartialView("_MsgPartialWR", result);

        }

        [HttpPost]
        public ActionResult AnularRegistroPago(int pagoProcesId)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var result = pagosModel.AnularRegistroPago(pagoProcesId, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [Route("operaciones/pagos/exportar-recaudacion-temporal-pagos")]
        public ActionResult ExportarRecaudacionTemporal()
        {
            ViewBag.Title = "Exportar recaudación para el Temporal de Pagos";

            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(), "Value", "TextDisplay"); 

            return View();
        }

        [HttpPost]
        public ActionResult ExportarRecaudacionTemporalPost(int cboEntFinan, TipoEstudio? cboTipoEst, string fechaDesde, string fechaHasta)
        {
            DateTime fecDesde = DateTime.Parse(fechaDesde);
            DateTime fecHasta = DateTime.Parse(fechaHasta);
            string nombreEntidad = new CultureInfo("es-MX", false).TextInfo.ToTitleCase(entidadRecaudadora.Find(cboEntFinan).NombreEntidad.ToLower()).Replace(" ", "");
            string tipoEstudio = cboTipoEst.HasValue ?  "_" + cboTipoEst.Value.ToString() : string.Empty;

            try
            {
                MemoryStream memoryStream = pagosModel.ExportarInformacionTemporalPagos(cboEntFinan, fecDesde, fecHasta, cboTipoEst);
                return File(memoryStream, "text/plain", $"Recaudacion{nombreEntidad}{tipoEstudio}_de_{fecDesde.ToString("yyyyMMdd")}_a_{fecHasta.ToString("yyyyMMdd")}.txt");
            }
            catch (Exception ex)
            {
                return Content(ex.Message);
            }

        }
    }
}
