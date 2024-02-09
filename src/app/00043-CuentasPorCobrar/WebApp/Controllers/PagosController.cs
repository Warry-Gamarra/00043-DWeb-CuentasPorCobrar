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
using Domain.Entities;
using System.Web.Http.Results;

namespace WebApp.Controllers
{
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
        private readonly DevolucionPagoModel _devolucionPagoModel;

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
            _devolucionPagoModel = new DevolucionPagoModel();
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("consultas/pagos-realizados/{anio}")]
        public ActionResult Index(int anio)
        {
            ViewBag.Title = "Pagos Registrados";

            var model = new List<DatosPagoViewModel>();

            return View(model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/generar-archivos-pago")]
        public ActionResult ExportarDatosPago()
        {
            var model = new FiltroEnvioObligacionesViewModel()
            {
                I_Anio = DateTime.Now.Year,
                E_TipoEstudio = TipoEstudio.Pregrado
            };

            ViewBag.Title = "Generar archivos de pago";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios(null);

            ViewBag.Dependencias = programasClientFacade.GetFacultades(TipoEstudio.Pregrado, null);

            ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", model.I_EntidadFinanciera);

            return View(model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
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

                ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios(null);

                ViewBag.Dependencias = model.E_TipoEstudio.HasValue ? programasClientFacade.GetFacultades(model.E_TipoEstudio.Value, null) : new List<SelectViewModel>();

                ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", model.I_EntidadFinanciera);

                ModelState.AddModelError("", ex.Message);

                return View("ExportarDatosPago", model);
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
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


        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        public ActionResult ImportarPagoObligaciones()
        {
            ViewBag.Title = "Cargar pagos de obligaciones";

            var model = pagosModel.ListarArchivosCargados(TipoArchivoEntFinan.Recaudacion_Obligaciones);

            return View(model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/cargar-pagos/seleccionar-archivo/obligaciones")]
        public ActionResult SeleccionarArchivoObligaciones()
        {
            ViewBag.Tipo = "(OBLIGACIONES)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay");
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay");

            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Obligacion };

            return PartialView("_SeleccionarArchivoObligaciones", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        public ActionResult ImportarPagoTasas()
        {
            ViewBag.Title = "Cargar pagos de tasas";

            var model = pagosModel.ListarArchivosCargados(TipoArchivoEntFinan.Recaudacion_Tasas);

            return View(model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/cargar-pagos/seleccionar-archivo/tasas")]
        public ActionResult SeleccionarArchivoTasas()
        {
            ViewBag.Tipo = "(TASAS)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            
            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Tasa }; ;

            return PartialView("_SeleccionarArchivoTasas", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult CargarArchivoPago(IEnumerable<HttpPostedFileBase> file, CargarArchivoViewModel model)
        {
            string directorioCarga = AppConfiguration.DirectorioCarga() + "Pagos/";

            string nombreBanco = entidadRecaudadora.Find(model.EntidadRecaudadora).NombreEntidad;

            ImportacionPagoResponse generalResult = new ImportacionPagoResponse();

            foreach (var item in file)
            {
                var result = pagosModel.CargarArchivoPagos(Server.MapPath(directorioCarga), item, model, WebSecurity.CurrentUserId);

                switch (model.TipoArchivo)
                {
                    case TipoPago.Obligacion:
                        generalResult.AgregarObligacionesObservadas(result.ListaResultadosOblig);
                        break;

                    case TipoPago.Tasa:
                        generalResult.AgregarTasasObservadas(result.ListaResultadosTasas);
                        break;
                }
            }
            
            if (generalResult.Success)
            {
                WebApp.Models.ResponseModel.Success(generalResult);
            }
            else
            {
                WebApp.Models.ResponseModel.Error(generalResult);
            }

            switch (model.TipoArchivo)
            {
                case TipoPago.Obligacion:
                    Session["PAGO_OBLIG_RESULT"] = generalResult.ListaResultadosOblig;
                    break;
                case TipoPago.Tasa:
                    Session["PAGO_TASA_RESULT"] = generalResult.ListaResultadosTasas;
                    break;
            }

            Session["BANCO_PAGO"] = nombreBanco;

            var jsonResponse = Json(generalResult, JsonRequestBehavior.AllowGet);
            //jsonResponse.MaxJsonLength = int.MaxValue;
            return jsonResponse;
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpGet]
        public ActionResult DescargarResultadoPagoObligaciones()
        {
            if (Session["PAGO_OBLIG_RESULT"] == null)
                return RedirectToAction("ImportarPagoObligaciones", "Pagos");

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("PagoObligaciones");
                var currentRow = 1;

                string nomBanco = Session["BANCO_PAGO"].ToString();

                worksheet.Cell(currentRow, 1).Value = "Archivo";
                worksheet.Cell(currentRow, 2).Value = "Banco";
                worksheet.Cell(currentRow, 3).Value = "CodOperaciÓn";
                worksheet.Cell(currentRow, 4).Value = "CodInterno";
                worksheet.Cell(currentRow, 5).Value = "CodAlumno";
                worksheet.Cell(currentRow, 6).Value = "NomAlumno";
                worksheet.Cell(currentRow, 7).Value = "CuotaPago";
                worksheet.Cell(currentRow, 8).Value = "FechaVcto";
                worksheet.Cell(currentRow, 9).Value = "FechaPago";
                worksheet.Cell(currentRow, 10).Value = "Cantidad";
                worksheet.Cell(currentRow, 11).Value = "Moneda";
                worksheet.Cell(currentRow, 12).Value = "MontoPago";
                worksheet.Cell(currentRow, 13).Value = "InteresMoratorio";
                worksheet.Cell(currentRow, 14).Value = "LugarPago";
                worksheet.Cell(currentRow, 15).Value = "InformacionAdicional";
                worksheet.Cell(currentRow, 16).Value = "Registrado";
                worksheet.Cell(currentRow, 17).Value = "Estado";

                var resultados = (IEnumerable<Domain.Entities.PagoObligacionObsEntity>)Session["PAGO_OBLIG_RESULT"];

                foreach (var item in resultados.OrderBy(x => x.D_FecPago))
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.T_SourceFileName);
                    worksheet.Cell(currentRow, 2).SetValue<string>(nomBanco);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodigoInterno); 
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.T_ProcesoDesc);
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.D_FecVencto.ToString(FormatosDateTime.BASIC_DATE));
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.D_FecPago.ToString(FormatosDateTime.BASIC_DATETIME));
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.I_Cantidad.ToString());
                    worksheet.Cell(currentRow, 11).SetValue<string>(item.C_Moneda);
                    worksheet.Cell(currentRow, 12).SetValue<decimal?>(item.I_MontoPago);
                    worksheet.Cell(currentRow, 13).SetValue<decimal?>(item.I_InteresMora);
                    worksheet.Cell(currentRow, 14).SetValue<string>(item.T_LugarPago);
                    worksheet.Cell(currentRow, 15).SetValue<string>(item.T_InformacionAdicional);
                    worksheet.Cell(currentRow, 16).SetValue<string>(item.B_Success ? "Sí" : "No");
                    worksheet.Cell(currentRow, 17).SetValue<string>(item.T_ErrorMessage);
                }

                worksheet.Range(worksheet.Cell(2, 12), worksheet.Cell(currentRow, 13)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de pago de obligaciones.xlsx");
                }
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpGet]
        public ActionResult DescargarResultadoPagoTasas()
        {
            if (Session["PAGO_TASA_RESULT"] == null)
                return RedirectToAction("ImportarPagoTasas", "Pagos");

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("PagoTasas");
                var currentRow = 1;

                string nomBanco = Session["BANCO_PAGO"].ToString();

                worksheet.Cell(currentRow, 1).Value = "Archivo";
                worksheet.Cell(currentRow, 2).Value = "Banco";
                worksheet.Cell(currentRow, 3).Value = "CodDepositante";
                worksheet.Cell(currentRow, 4).Value = "NomDepositante";
                worksheet.Cell(currentRow, 5).Value = "CodServicio";
                worksheet.Cell(currentRow, 6).Value = "CodTasa";
                worksheet.Cell(currentRow, 7).Value = "TasaDesc";
                worksheet.Cell(currentRow, 8).Value = "CodOperacion";
                worksheet.Cell(currentRow, 9).Value = "Referencia";
                worksheet.Cell(currentRow, 10).Value = "CodigoInterno (BCP)";
                worksheet.Cell(currentRow, 11).Value = "FechaPago";
                worksheet.Cell(currentRow, 12).Value = "Cantidad";
                worksheet.Cell(currentRow, 13).Value = "Moneda";
                worksheet.Cell(currentRow, 14).Value = "MontoPago";
                worksheet.Cell(currentRow, 15).Value = "Recargo";
                worksheet.Cell(currentRow, 16).Value = "LugarPago";
                worksheet.Cell(currentRow, 17).Value = "InformacionAdicional";
                worksheet.Cell(currentRow, 18).Value = "Registrado";
                worksheet.Cell(currentRow, 19).Value = "Estado";

                var resultados = (IEnumerable<Domain.Entities.PagoTasaObsEntity>)Session["PAGO_TASA_RESULT"];

                foreach (var item in resultados.OrderBy(x => x.D_FecPago))
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.T_SourceFileName);
                    worksheet.Cell(currentRow, 2).SetValue<string>(nomBanco);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.C_CodServicio);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.C_CodTasa);
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.T_TasaDesc);
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.C_Referencia);
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.C_CodigoInterno);
                    worksheet.Cell(currentRow, 11).SetValue<string>(item.D_FecPago.ToString(FormatosDateTime.BASIC_DATETIME));
                    worksheet.Cell(currentRow, 12).SetValue<string>(item.I_Cantidad.ToString());
                    worksheet.Cell(currentRow, 13).SetValue<string>(item.C_Moneda);
                    worksheet.Cell(currentRow, 14).SetValue<decimal?>(item.I_MontoPago);
                    worksheet.Cell(currentRow, 15).SetValue<decimal?>(item.I_InteresMora);
                    worksheet.Cell(currentRow, 16).SetValue<string>(item.T_LugarPago);
                    worksheet.Cell(currentRow, 17).SetValue<string>(item.T_InformacionAdicional);
                    worksheet.Cell(currentRow, 18).SetValue<string>(item.B_Success ? "Sí" : "No");
                    worksheet.Cell(currentRow, 19).SetValue<string>(item.T_ErrorMessage);
                }

                worksheet.Range(worksheet.Cell(2, 14), worksheet.Cell(currentRow, 15)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de pago de tasas.xlsx");
                }
            }
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
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

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
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

                ResponseModel.Error(result, "Ha ocurrido un error con el envío de datos" + details);
            }

            return PartialView("_MsgRegistrarPagoObligacion", result);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
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

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult RegistrarPagoTasa(PagoTasaViewModel model)
        {
            ImportacionPagoResponse result = new ImportacionPagoResponse();

            if (ModelState.IsValid)
            {
                try
                {
                    int currentUserID = WebSecurity.CurrentUserId;

                    result = pagosModel.GrabarPagoTasa(model, currentUserID);

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

                ResponseModel.Error(result, "Ha ocurrido un error con el envío de datos" + details);
            }

            return PartialView("_MsgRegistrarPagoTasa", result);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/actualizar-pagos")]
        public ActionResult Actualizar()
        {
            ViewBag.Title = "Actualizar información de pagos";

            var model = pagosModel.ListarPagosRegistrados(DateTime.Now.Date, DateTime.Now.Date, null, null);
            ViewBag.EntidadRecaudadora = new SelectList(entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.Dependencia = new SelectList(_dependenciaModel.Find(enabled: true), dataValueField: "DependenciaID", dataTextField: "DependDesc");

            return View(model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult ObtenerPagosRegistrados(string txtFecDesde, string txtFecHasta, int? cboEntRecauda, int? cboDependencia)
        {
            DateTime fecDesde = DateTime.Parse(txtFecDesde);
            DateTime fecHasta = DateTime.Parse(txtFecHasta);

            var model = pagosModel.ListarPagosRegistrados(fecDesde, fecHasta, cboDependencia, cboEntRecauda);

            return PartialView("_ResultadoConsultaPagos", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/pagos/{id}/ver-detalle")]
        public ActionResult Detalle(int id)
        {
            ViewBag.Title = "Detalles del pago";

            var model = pagosModel.ObtenerDatosPago(id);

            return PartialView("_DetallesPago", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/pagos/{id}/registrar-nro-siaf")]
        public ActionResult RegistrarSiaf(int[] pagosId)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var model = pagosModel.ObtenerDatosPago(pagosId[0]);

            return PartialView("_RegistrarSiaf", model);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult RegistrarSiafLote(int[] pagosId, int nroSiaf)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var result = pagosModel.GrabarNroSiafPago(pagosId, nroSiaf, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);

        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
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

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult AnularRegistroPago(int pagoProcesId)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var result = pagosModel.AnularRegistroPago(pagoProcesId, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [Route("operaciones/pagos/exportar-recaudacion-temporal-pagos")]
        public ActionResult ExportarRecaudacionTemporal()
        {
            ViewBag.Title = "Exportar recaudación para el Temporal de Pagos";

            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(null, true), "Value", "TextDisplay");
            ViewBag.TipoPago = new SelectList(generalServiceFacade.Listar_TiposPago(), "Value", "TextDisplay");

            return View();
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        public ActionResult ExportarRecaudacionTemporalPost(int cboEntFinan, TipoEstudio? cboTipoEst, string fechaDesde, string fechaHasta)
        {
            DateTime fecDesde = DateTime.Parse(fechaDesde);
            DateTime fecHasta = DateTime.Parse(fechaHasta);
            string nombreEntidad = new CultureInfo("es-MX", false).TextInfo.ToTitleCase(entidadRecaudadora.Find(cboEntFinan).NombreEntidad.ToLower()).Replace(" ", "");
            string tipoEstudio = cboTipoEst.HasValue ? "_" + cboTipoEst.Value.ToString() : string.Empty;

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

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        public ActionResult AsignarPagoObligacion(int obligacionID)
        {
            var obligacion = obligacionServiceFacade.Obtener_CuotaPago(obligacionID);

            ViewBag.Title = "Asignar Pago";

            ViewBag.CuotaPago = obligacion;

            if (!obligacion.B_Pagado)
            {
                var parametroBusqueda = new ConsultaPagosBancoObligacionesViewModel()
                {
                    codAlumno = obligacion.C_CodAlu
                };

                ViewBag.Pagos = pagosModel.ListarPagoBancoObligacion(parametroBusqueda)
                    .Where(x => x.I_CondicionPagoID != (int)CondicionPago.Correcto && x.I_CondicionPagoID != (int)CondicionPago.Extorno)
                    .OrderBy(x => x.D_FecPago);
            }
            
            return PartialView("_AsignarPagoObligacion");
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        [HandleJsonExceptionAttribute]
        public ActionResult AsignarPagoObservado(int idObligacion, int idPagoBanco, string motivoCoreccion)
        {
            Response response;

            var obligacion = obligacionServiceFacade.Obtener_CuotaPago(idObligacion);

            var pago = pagosModel.ObtenerPagoBanco(idPagoBanco);

            if (pago == null)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El pago seleccionado no existe."
                };
            }
            else if (obligacion.B_Pagado)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "La obligación ya tiene un pago asignado."
                };
            }
            else if (pago.I_CondicionPagoID == (int)CondicionPago.Correcto)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El pago ya ha sido asignado a una obligación."
                };
            }
            else if (pago.I_CondicionPagoID == (int)CondicionPago.Extorno)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "Los extornos no se pueden utilizar para pagar una obligación."
                };
            }
            else if(_devolucionPagoModel.ExisteDevolucion(idPagoBanco))
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El pago tiene registrado una devolución."
                };
            }
            else
            {
                response = pagosModel.AsignarPagoObligacion(idObligacion, idPagoBanco, WebSecurity.CurrentUserId, motivoCoreccion);
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA + ", " + RoleNames.CONSULTA + ", " + RoleNames.DEPENDENCIA)]
        public ActionResult VerPagosObligacion(int obligacionID, bool soloLectura = false)
        {
            var obligacion = obligacionServiceFacade.Obtener_CuotaPago(obligacionID);

            var pagosDetalle = pagosModel.ListarPagosBancoPorObligacion(obligacionID);

            ViewBag.Title = "Lista de Pagos";

            ViewBag.CuotaPago = obligacion;

            ViewBag.Pagos = pagosDetalle;

            ViewBag.SoloLectura = soloLectura;

            return PartialView("_VerPagosObligacion");
        }

        [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
        [HttpPost]
        [HandleJsonExceptionAttribute]
        public ActionResult DesenlazarPagoObligacion(int idPagoBanco, string motivoCoreccion)
        {
            Response response = null;

            var pago = pagosModel.ObtenerPagoBanco(idPagoBanco);

            if (pago == null)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El pago seleccionado no existe."
                };
            }
            else if (pago.I_CondicionPagoID != (int)CondicionPago.Correcto)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "La condición del pago ya ha sido modificado con anterioridad."
                };
            }
            else
            {
                response = pagosModel.DesenlazarPagoObligacion(idPagoBanco, WebSecurity.CurrentUserId, motivoCoreccion);
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }
    }
}
