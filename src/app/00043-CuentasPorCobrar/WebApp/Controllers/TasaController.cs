using Domain.Helpers;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize(Roles = RoleNames.ADMINISTRADOR + ", " + RoleNames.TESORERIA)]
    public class TasaController : Controller
    {
        private int? _dependenciaUsuarioId;
        private SelectModel _selectModel;
        private ConceptoModel _conceptoModel;
        private CuentaDepositoModel _cuentasDeposito;
        PagosModel _pagosModel;

        public ITasaServiceFacade _tasaService;

        public TasaController()
        {
            _selectModel = new SelectModel();
            _conceptoModel = new ConceptoModel();
            _cuentasDeposito = new CuentaDepositoModel();
            _pagosModel = new PagosModel();

            _tasaService = new TasaServiceFacade();
            
            if (WebSecurity.IsAuthenticated)
            {
                _dependenciaUsuarioId = new UsersModel().Find(WebSecurity.CurrentUserId).DependenciaId;
            }
        }

        public ActionResult Index()
        {
            return View();
        }

        [Route("configuracion/tasas-y-servicios")]
        public ActionResult Tasas()
        {
            ViewBag.Title = "Tasas y Servicios";

            var lista = _tasaService.listarTodoTasas();

            return View(lista);
        }

        [Route("configuracion/tasas-y-servicios/agregar-tasa/")]
        public ActionResult CreateTasa()
        {
            ViewBag.Title = "Registrar Concepto";

            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(TipoPago.Tasa, true), "Id", "NombreConcepto");

            ViewBag.ListaCtasDepositoServicios = _selectModel.GetCtaDepoServicioParaTasas();

            var model = new RegistrarTasaViewModel()
            {
                MostrarFormulario = false,
                PermitirCambiarTasa = true
            };

            return PartialView("_RegistrarConceptosPagoTasa", model);
        }


        [Route("configuracion/tasas-y-servicios/editar-tasa/{id}")]
        public ActionResult EditTasa(int id)
        {
            ViewBag.Title = "Editar Tasa";

            var model = _tasaService.ObtenerTasaUnfv(id);

            model.MostrarFormulario = true;

            model.PermitirCambiarTasa = false;

            model.CtaDepoServicioID = _tasaService.ObtenerCtaDepositoServicioIDs(id);

            ViewBag.ListaCtasDepositoServicios = _selectModel.GetCtaDepoServicioParaTasas(model.CtaDepoServicioID);

            return PartialView("_RegistrarConceptosPagoTasa", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistrarTasaViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _tasaService.Grabar_TasaUnfv(model, WebSecurity.CurrentUserId);

                if (!result.Value)
                {
                    ModelState.AddModelError("", result.Message);
                }
            }
            else
            {
                string details = "";
                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += "\n " + error.ErrorMessage;
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos.\n" + details);
            }

            return PartialView("_MsgRegistrarConceptoTasa", result);
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _tasaService.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "Tasa"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ConsultaPagoTasa(ConsultaPagoTasasViewModel model)
        {
            ViewBag.Title = "Gestión Pago de Tasas";

            if (model.buscar)
            {
                model.resultado = _tasaService.listarPagoTasas(model);
            }

            ViewBag.EntidadesFinancieras = new SelectList(_selectModel.GetEntidadesFinancieras(), "Value", "TextDisplay", model.entidadFinanciera);

            ViewBag.CtaDeposito = new SelectList(
                model.entidadFinanciera.HasValue ? _selectModel.GetCtasDeposito(model.entidadFinanciera.Value) : new List<SelectViewModel>(), "Value", "TextDisplay", model.idCtaDeposito);

            return View(model);
        }

        public ActionResult EditarPagoTasa(int id)
        {
            ViewBag.Title = "Información del Pago";

            ViewBag.Tasas = new SelectList(_tasaService.listarTasas(), "Value", "TextDisplay");

            var pago = _tasaService.ObtenerPagoTasa(id);

            var model = new EditarPagoTasa()
            {
                I_PagoBancoID = pago.I_PagoBancoID,
                I_TasaUnfvID = pago.I_TasaUnfvID,
                I_NuevaTasaUnfvID = pago.I_TasaUnfvID,
                C_CodTasa = pago.C_CodTasa,
                T_ConceptoPagoDesc = pago.T_ConceptoPagoDesc,
                M_Monto = pago.M_Monto ?? 0,
                C_CodOperacion = pago.C_CodOperacion,
                C_CodigoInterno = pago.C_CodigoInterno,
                C_CodDepositante = pago.C_CodDepositante,
                T_NomDepositante = pago.T_NomDepositante,
                T_EntidadDesc = pago.T_EntidadDesc,
                C_NumeroCuenta = pago.C_NumeroCuenta,
                T_FecPago = pago.T_FecPago,
                I_MontoTotalPagado = pago.I_MontoTotalPagado,
                T_Observacion = pago.T_Observacion
            };

            return PartialView("_DetallePagoTasa", model);
        }

        public ActionResult GuardarPagoTasa(EditarPagoTasa model)
        {
            var result = _pagosModel.ActualizarPagoTasa(model.I_PagoBancoID, model.C_CodDepositante, model.I_NuevaTasaUnfvID ?? model.I_TasaUnfvID,
                model.T_Observacion, WebSecurity.CurrentUserId);

            return PartialView("_MsgGuardarPagoTasa", result);
        }
    }
}