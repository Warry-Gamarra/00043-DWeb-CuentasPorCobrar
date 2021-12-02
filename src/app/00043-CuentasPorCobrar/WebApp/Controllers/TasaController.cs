using Domain.Helpers;
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
    public class TasaController : Controller
    {
        private int? _dependenciaUsuarioId;
        private SelectModel _selectModel;
        private ConceptoModel _conceptoModel;
        private CuentaDepositoModel _cuentasDeposito;

        public ITasaServiceFacade _tasaService;

        public TasaController()
        {
            _selectModel = new SelectModel();
            _conceptoModel = new ConceptoModel();
            _cuentasDeposito = new CuentaDepositoModel();

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

            var ctasDeposito = new List<SelectViewModel>();

            foreach (var item in _cuentasDeposito.Listar_Combo_CtaDepositoHabilitadas().Select(x => x.ItemsGroup))
            {
                ctasDeposito.AddRange(item);
            }

            ViewBag.CtasDeposito = new SelectList(ctasDeposito, "Value", "TextDisplay", "NameGroup", null, null);

            ViewBag.CodServicioBcoComercioTasas = new SelectList(_selectModel.GetServiciosBcoComercioTasas(), "Value", "TextDisplay");

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

            var ctasDeposito = new List<SelectViewModel>();

            foreach (var item in _cuentasDeposito.Listar_Combo_CtaDepositoHabilitadas().Select(x => x.ItemsGroup))
            {
                ctasDeposito.AddRange(item);
            }

            model.CtaDepositoID = _tasaService.ObtenerCtaDepositoIDs(id);

            ViewBag.CtasDeposito = new SelectList(ctasDeposito, "Value", "TextDisplay", "NameGroup", model.CtaDepositoID, null);

            model.servicioID = _tasaService.ObtenerServicioIDs(id);

            ViewBag.CodServicioBcoComercioTasas = new SelectList(_selectModel.GetServiciosBcoComercioTasas(), "Value", "TextDisplay", model.servicioID);

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
    }
}