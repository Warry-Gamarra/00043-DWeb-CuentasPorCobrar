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
            var model = new FiltroEnvioObligacionesViewModel()
            {
                I_Anio = DateTime.Now.Year,
                E_TipoEstudio = TipoEstudio.Pregrado
            };

            ViewBag.Title = "Generar archivos de pago";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

            ViewBag.Dependencias = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", model.I_EntidadFinanciera);

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

                ViewBag.Dependencias = model.E_TipoEstudio.HasValue ? programasClientFacade.GetFacultades(model.E_TipoEstudio.Value) : new List<SelectViewModel>();

                ViewBag.EntidadesFinancieras = new SelectList(selectModels.GetEntidadesFinancieras(), "Value", "TextDisplay", model.I_EntidadFinanciera);

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

            var model = pagosModel.ListarArchivosCargados(TipoArchivoEntFinan.Recaudacion_Obligaciones);

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

            return PartialView("_SeleccionarArchivoObligaciones", model);
        }

        //[Route("operaciones/cargar-pagos/tasas")]
        public ActionResult ImportarPagoTasas()
        {
            ViewBag.Title = "Cargar pagos de tasas";

            var model = pagosModel.ListarArchivosCargados(TipoArchivoEntFinan.Recaudacion_Tasas);

            return View(model);
        }


        [Route("operaciones/cargar-pagos/seleccionar-archivo/tasas")]
        public ActionResult SeleccionarArchivoTasas()
        {
            ViewBag.Tipo = "(TASAS)";
            ViewBag.EntidadesFinancieras = new SelectList(ListaEntidadesFinancieras(), "Value", "TextDisplay");
            
            var model = new CargarArchivoViewModel() { TipoArchivo = TipoPago.Tasa }; ;

            return PartialView("_SeleccionarArchivoTasas", model);
        }


        [HttpPost]
        public ActionResult CargarArchivoPago(HttpPostedFileBase file, CargarArchivoViewModel model)
        {
            var directorioCarga = AppConfiguration.DirectorioCarga() + "Pagos/";

            var result = pagosModel.CargarArchivoPagos(Server.MapPath(directorioCarga), file, model, WebSecurity.CurrentUserId);

            string nombreBanco = entidadRecaudadora.Find(model.EntidadRecaudadora).NombreEntidad;

            Session["BANCO_PAGO"] = nombreBanco;

            switch (model.TipoArchivo)
            {
                case TipoPago.Obligacion:
                    Session["PAGO_OBLIG_RESULT"] = result.ListaResultadosOblig;
                    break;
                case TipoPago.Tasa:
                    Session["PAGO_TASA_RESULT"] = result.ListaResultadosTasas;
                    break;
            }

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

                string nomBanco = Session["BANCO_PAGO"].ToString();

                worksheet.Cell(currentRow, 1).Value = "Banco";
                worksheet.Cell(currentRow, 2).Value = "CodOperacion";
                worksheet.Cell(currentRow, 3).Value = "CodInterno";
                worksheet.Cell(currentRow, 4).Value = "CodAlumno";
                worksheet.Cell(currentRow, 5).Value = "NomAlumno";
                worksheet.Cell(currentRow, 6).Value = "CuotaPago";
                worksheet.Cell(currentRow, 7).Value = "FechaVcto";
                worksheet.Cell(currentRow, 8).Value = "FechaPago";
                worksheet.Cell(currentRow, 9).Value = "Cantidad";
                worksheet.Cell(currentRow, 10).Value = "Moneda";
                worksheet.Cell(currentRow, 11).Value = "MontoPago";
                worksheet.Cell(currentRow, 12).Value = "InteresMoratorio";
                worksheet.Cell(currentRow, 13).Value = "LugarPago";
                worksheet.Cell(currentRow, 14).Value = "InformacionAdicional";
                worksheet.Cell(currentRow, 15).Value = "Estado";
                worksheet.Cell(currentRow, 16).Value = "Mensaje";

                var resultados = (IEnumerable<Domain.Entities.PagoObligacionObsEntity>)Session["PAGO_OBLIG_RESULT"];

                foreach (var item in resultados.OrderBy(x => x.D_FecPago))
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(nomBanco);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodigoInterno); 
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.T_ProcesoDesc);
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.D_FecVencto.ToString(FormatosDateTime.BASIC_DATE));
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.D_FecPago.ToString(FormatosDateTime.BASIC_DATETIME));
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.I_Cantidad.ToString());
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.C_Moneda);
                    worksheet.Cell(currentRow, 11).SetValue<decimal?>(item.I_MontoPago);
                    worksheet.Cell(currentRow, 12).SetValue<decimal?>(item.I_InteresMora);
                    worksheet.Cell(currentRow, 13).SetValue<string>(item.T_LugarPago);
                    worksheet.Cell(currentRow, 14).SetValue<string>(item.T_InformacionAdicional);
                    worksheet.Cell(currentRow, 15).SetValue<string>(item.B_Success ? "Correcto" : "Observado");
                    worksheet.Cell(currentRow, 16).SetValue<string>(item.T_ErrorMessage);
                }

                worksheet.Range(worksheet.Cell(2, 11), worksheet.Cell(currentRow, 12)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de pago de obligaciones.xlsx");
                }
            }
        }

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

                worksheet.Cell(currentRow, 1).Value = "Banco";
                worksheet.Cell(currentRow, 2).Value = "CodDepositante";
                worksheet.Cell(currentRow, 3).Value = "NomDepositante";
                worksheet.Cell(currentRow, 4).Value = "CodTasa";
                worksheet.Cell(currentRow, 5).Value = "TasaDesc";
                worksheet.Cell(currentRow, 6).Value = "CodOperacion";
                worksheet.Cell(currentRow, 7).Value = "Referencia";
                worksheet.Cell(currentRow, 8).Value = "CodigoInterno (BCP)";
                worksheet.Cell(currentRow, 9).Value = "FechaPago";
                worksheet.Cell(currentRow, 10).Value = "Cantidad";
                worksheet.Cell(currentRow, 11).Value = "Moneda";
                worksheet.Cell(currentRow, 12).Value = "MontoPago";
                worksheet.Cell(currentRow, 13).Value = "Recargo";
                worksheet.Cell(currentRow, 14).Value = "LugarPago";
                worksheet.Cell(currentRow, 15).Value = "InformacionAdicional";
                worksheet.Cell(currentRow, 16).Value = "Estado";
                worksheet.Cell(currentRow, 17).Value = "Mensaje";

                var resultados = (IEnumerable<Domain.Entities.PagoTasaObsEntity>)Session["PAGO_TASA_RESULT"];

                foreach (var item in resultados.OrderBy(x => x.D_FecPago))
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(nomBanco);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodDepositante);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.T_NomDepositante);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodTasa);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_TasaDesc);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.C_CodOperacion);
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.C_Referencia);
                    worksheet.Cell(currentRow, 8).SetValue<string>(item.C_CodigoInterno);
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.D_FecPago.ToString(FormatosDateTime.BASIC_DATETIME));
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.I_Cantidad.ToString());
                    worksheet.Cell(currentRow, 11).SetValue<string>(item.C_Moneda);
                    worksheet.Cell(currentRow, 12).SetValue<decimal?>(item.I_MontoPago);
                    worksheet.Cell(currentRow, 13).SetValue<decimal?>(item.I_InteresMora);
                    worksheet.Cell(currentRow, 14).SetValue<string>(item.T_LugarPago);
                    worksheet.Cell(currentRow, 15).SetValue<string>(item.T_InformacionAdicional);
                    worksheet.Cell(currentRow, 16).SetValue<string>(item.B_Success ? "Correcto" : "Observado");
                    worksheet.Cell(currentRow, 17).SetValue<string>(item.T_ErrorMessage);
                }

                worksheet.Range(worksheet.Cell(2, 12), worksheet.Cell(currentRow, 13)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de pago de tasas.xlsx");
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

                ResponseModel.Error(result, "Ha ocurrido un error con el envío de datos" + details);
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


        [Route("operaciones/actualizar-pagos")]
        public ActionResult Actualizar()
        {
            ViewBag.Title = "Actualizar información de pagos";

            var model = pagosModel.ListarPagosRegistrados(DateTime.Now.Date, DateTime.Now.Date, null, null);
            ViewBag.EntidadRecaudadora = new SelectList(entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.Dependencia = new SelectList(_dependenciaModel.Find(enabled: true), dataValueField: "DependenciaID", dataTextField: "DependDesc");

            return View(model);
        }

        [HttpPost]
        public ActionResult ObtenerPagosRegistrados(string txtFecDesde, string txtFecHasta, int? cboEntRecauda, int? cboDependencia)
        {
            DateTime fecDesde = DateTime.Parse(txtFecDesde);
            DateTime fecHasta = DateTime.Parse(txtFecHasta);

            var model = pagosModel.ListarPagosRegistrados(fecDesde, fecHasta, cboDependencia, cboEntRecauda);

            return PartialView("_ResultadoConsultaPagos", model);
        }


        [Route("operaciones/pagos/{id}/ver-detalle")]
        public ActionResult Detalle(int id)
        {
            ViewBag.Title = "Detalles del pago";

            var model = pagosModel.ObtenerDatosPago(id);

            return PartialView("_DetallesPago", model);
        }

        [Route("operaciones/pagos/{id}/registrar-nro-siaf")]
        public ActionResult RegistrarSiaf(int[] pagosId)
        {
            ViewBag.Title = "Registrar Nro. SIAF";

            var model = pagosModel.ObtenerDatosPago(pagosId[0]);

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
            ViewBag.TipoPago = new SelectList(generalServiceFacade.Listar_TiposPago(), "Value", "TextDisplay");

            return View();
        }

        [HttpPost]
        public ActionResult ExportarRecaudacionTemporalPost(int cboEntFinan, TipoEstudio? cboTipoEst, TipoPago cboTipoPago, string fechaDesde, string fechaHasta)
        {
            DateTime fecDesde = DateTime.Parse(fechaDesde);
            DateTime fecHasta = DateTime.Parse(fechaHasta);
            string nombreEntidad = new CultureInfo("es-MX", false).TextInfo.ToTitleCase(entidadRecaudadora.Find(cboEntFinan).NombreEntidad.ToLower()).Replace(" ", "");
            string tipoEstudio = cboTipoEst.HasValue ? "_" + cboTipoEst.Value.ToString() : string.Empty;

            try
            {
                MemoryStream memoryStream = pagosModel.ExportarInformacionTemporalPagos(cboEntFinan, fecDesde, fecHasta, cboTipoEst, cboTipoPago);
                return File(memoryStream, "text/plain", $"Recaudacion{nombreEntidad}{tipoEstudio}_de_{fecDesde.ToString("yyyyMMdd")}_a_{fecHasta.ToString("yyyyMMdd")}.txt");
            }
            catch (Exception ex)
            {
                return Content(ex.Message);
            }

        }

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
                    .Where(x => x.I_CondicionPagoID != (int)CatalogoTipoPago.Correcto && x.I_CondicionPagoID != (int)CatalogoTipoPago.Extorno)
                    .OrderBy(x => x.D_FecPago);
            }
            
            return PartialView("_AsignarPagoObligacion");
        }

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
            else if (pago.I_CondicionPagoID == (int)CatalogoTipoPago.Correcto)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "El pago ya ha sido asignado a una obligación."
                };
            }
            else if (pago.I_CondicionPagoID == (int)CatalogoTipoPago.Extorno)
            {
                response = new Response()
                {
                    Value = false,
                    Message = "Los extornos no se pueden utilizar para pagar una obligación."
                };
            }
            else
            {
                response = pagosModel.AsignarPagoObligacion(idObligacion, idPagoBanco, WebSecurity.CurrentUserId, motivoCoreccion);
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        public ActionResult VerPagosObligacion(int obligacionID)
        {
            var obligacion = obligacionServiceFacade.Obtener_CuotaPago(obligacionID);

            var pagosDetalle = pagosModel.ListarPagosBancoPorObligacion(obligacionID);

            ViewBag.Title = "Lista de Pagos";

            ViewBag.CuotaPago = obligacion;

            ViewBag.Pagos = pagosDetalle;

            return PartialView("_VerPagosObligacion");
        }

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
            else if (pago.I_CondicionPagoID != (int)CatalogoTipoPago.Correcto)
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
