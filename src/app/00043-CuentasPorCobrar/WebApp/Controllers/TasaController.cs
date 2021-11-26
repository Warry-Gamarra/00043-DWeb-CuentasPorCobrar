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
        private ProcesoModel _procesoModel;
        private int? _dependenciaUsuarioId;
        private SelectModel _selectModel;
        private ConceptoPagoModel _conceptoPagoModel;
        private ConceptoModel _conceptoModel;
        private CategoriaPagoModel _categoriaPagoModel;
        private CuentaDepositoModel _cuentasDeposito;

        public ITasaServiceFacade _tasaService;

        public TasaController()
        {
            _procesoModel = new ProcesoModel();
            _selectModel = new SelectModel();
            _conceptoPagoModel = new ConceptoPagoModel();
            _conceptoModel = new ConceptoModel();
            _categoriaPagoModel = new CategoriaPagoModel();
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

        [Route("configuracion/tasas-y-servicios/habilitar-grupo")]
        public ActionResult CreateGrupoTasa()
        {
            ViewBag.Title = "Nueva Cuota de Pago";

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find(), "Id", "Nombre");
            ViewBag.CtasDeposito = new SelectList(new List<SelectViewModel>());

            return PartialView("_RegistrarProcesoTasa", new RegistroProcesoViewModel()
            {
                CtasBcoComercio = _cuentasDeposito.Find().Where(x => x.EntidadFinancieraId == Bancos.BANCO_COMERCIO_ID).Select(x => x.Id.Value).ToArray()
            });
        }


        [Route("configuracion/tasas-y-servicios/{id}/editar")]
        public ActionResult EditGrupoTasa(int id)
        {
            ViewBag.Title = "Editar Cuota de Pago";

            RegistroProcesoViewModel model = _procesoModel.Obtener_Proceso(id);

            var ctasCategoria = new List<SelectViewModel>();

            foreach (var item in _procesoModel.Listar_Combo_CtaDepositoHabilitadas(model.CategoriaId.Value).Select(x => x.ItemsGroup))
            {
                ctasCategoria.AddRange(item);
            }

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find().Where(x => x.Id == model.CategoriaId.Value), "Id", "Nombre");
            ViewBag.CtasDeposito = new SelectList(ctasCategoria, "Value", "TextDisplay", "NameGroup", model.CtaDepositoID, null);

            return PartialView("_RegistrarProcesoTasa", model);
        }

        [Route("configuracion/tasas-y-servicios/{procesoId}/tasas")]
        public ActionResult VerTasas(int procesoId)
        {
            ViewBag.ProcesoId = procesoId;

            var model = _procesoModel.ObtenerConceptosProceso(procesoId);

            return PartialView("_ListadoTasasProcesoGrupos", model);
        }

        [Route("configuracion/tasas-y-servicios/{procesoId}/agregar-tasa-concepto/")]
        public ActionResult CreateTasa(int procesoId)
        {
            ViewBag.Title = "Registrar Concepto";
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(TipoPago.Tasa), "Id", "NombreConcepto");


            var model = new RegistroConceptosProcesoViewModel(procesoId, _conceptoPagoModel)
            {
                MostrarFormulario = true
            };

            return PartialView("_RegistrarConceptosPagoTasa", model);
        }


        [Route("configuracion/tasas-y-servicios/{procesoId}/editar-tasa-concepto/{id}")]
        public ActionResult EditTasa(int procesoId, int id)
        {
            ViewBag.Title = "Editar Concepto";
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");

            var model = _conceptoPagoModel.ObtenerConceptoPagoProceso(procesoId, id);

            return PartialView("_RegistrarConceptosPagoTasa", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistroConceptosProcesoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _conceptoPagoModel.Grabar_ConceptoPago(model.ConceptoPago, WebSecurity.CurrentUserId);

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

            ViewBag.ProcesoId = model.ConceptoPago.I_ProcesoID;

            return PartialView("_MsgRegistrarConceptoObligacion", result);
        }
    }
}