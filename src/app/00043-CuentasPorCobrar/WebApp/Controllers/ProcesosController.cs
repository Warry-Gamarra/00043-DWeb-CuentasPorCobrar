using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class ProcesosController : Controller
    {
        ProcesoModel procesoModel;
        private readonly int? _dependenciaUsuarioId;
        private readonly SelectModels _selectModel;
        private readonly ConceptoPagoModel _conceptoModel;
        private readonly CategoriaPagoModel _categoriaPagoModel;
        private readonly CuentaDepositoModel _cuentasDeposito;

        public ProcesosController()
        {
            procesoModel = new ProcesoModel();
            _selectModel = new SelectModels();
            _conceptoModel = new ConceptoPagoModel();
            _categoriaPagoModel = new CategoriaPagoModel();
            _cuentasDeposito = new CuentaDepositoModel();

            if (WebSecurity.IsAuthenticated)
            {
                _dependenciaUsuarioId = new UsersModel().Find(WebSecurity.CurrentUserId).DependenciaId;
            }
        }


        public ActionResult Index()
        {
            ViewBag.Title = "Procesos y Conceptos";

            var lista = procesoModel.Listar_Procesos(2021);

            return View(lista);
        }

        [Route("configuracion/obligaciones-y-conceptos")]
        public ActionResult Obligaciones(int? anio, int? grado)
        {
            ViewBag.Title = "Obligaciones y conceptos";

            anio = anio ?? DateTime.Now.Year;
            grado = grado ?? 4;

            ViewBag.Anios = new SelectList(_selectModel.GetAnios(1990), "Value", "TextDisplay", anio);
            ViewBag.AnioSelect = anio;

            ViewBag.Message = TempData["Message"];

            return View("Obligaciones", procesoModel.Listar_Procesos(anio.Value));
        }

        [Route("configuracion/obligaciones-y-conceptos/{anio}/nueva-cuota-pago")]
        public ActionResult Create(int anio)
        {
            ViewBag.Title = "Nueva Cuota de Pago";

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find(), "Id", "Nombre");
            ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay", null);
            ViewBag.CtasDeposito = new SelectList(new List<SelectViewModel>());

            return PartialView("_RegistrarProcesoObligacion");
        }


        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Cuota de Pago";

            RegistroProcesoViewModel model = procesoModel.Obtener_Proceso(id);

            var ctasCategoria = new List<SelectViewModel>();

            foreach (var item in procesoModel.Listar_Combo_CtaDepositoHabilitadas(model.CategoriaId.Value).Select(x => x.ItemsGroup))
            {
                ctasCategoria.AddRange(item);
            }

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find().Where(x => x.Id == model.CategoriaId.Value), "Id", "Nombre");
            ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo().Where(x => x.Value == model.PerAcadId.ToString()), "Value", "TextDisplay", model.PerAcadId);
            ViewBag.CtasDeposito = new SelectList(ctasCategoria, "Value", "TextDisplay", "NameGroup", model.CtaDepositoID, null);

            return PartialView("_RegistrarProcesoObligacion", model);
        }


        [Route("configuracion/obligaciones-y-conceptos/{procesoId}/conceptos-de-pago")]
        public ActionResult VerConceptosProcceso(int procesoId)
        {

            ViewBag.Title = "Conceptos de Pago";

            var model = procesoModel.ObtenerConceptosProceso(procesoId);
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");

            return PartialView("_RegistrarProcesoConceptos", model);
        }

        [Route("configuracion/obligaciones-y-conceptos/{procesoId}/editar-concepto/{id}")]
        public ActionResult EditarConceptosPago(int procesoId)
        {

            ViewBag.Title = "Registrar Conceptos";

            var model = procesoModel.ObtenerConceptosProceso(procesoId);
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");

            return PartialView("_RegistrarProcesoConceptos", model);
        }



        //public ActionResult AgregarProcesosObligaciones(int catId, int anio)
        //{
        //    ViewBag.Title = "Agregar obligación";

        //    var model = procesoModel.ObtenerConceptosProceso(catId, anio);

        //    ViewBag.Lista_CtaDepoHabilitadas = new List<SelectViewModel>();
        //    ViewBag.Lista_CtaDepoProceso = new List<SelectViewModel>();
        //    ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay");
        //    ViewBag.CtasDeposito = new SelectList(_cuentasDeposito.Find(), "Id", "DescripcionFull", "EntidadFinanciera", model.CtasDepoId, null);
        //    ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");
        //    ViewBag.Dependencias = new SelectList(_selectModel.GetDependencias(), "Value", "TextDisplay", _dependenciaUsuarioId);


        //    return PartialView("_RegistrarProcesoObligacionCocepto", model);
        //}


        [Route("configuracion/tasas-y-servicios")]
        public ActionResult Tasas()
        {
            ViewBag.Title = "Tasas y Servicios";

            var lista = procesoModel.Listar_Tasas();
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");
            ViewBag.Dependencias = new SelectList(_selectModel.GetDependencias(), "Value", "TextDisplay", _dependenciaUsuarioId);

            return View("Tasas", lista);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistroProcesoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = procesoModel.Grabar_Proceso(model, WebSecurity.CurrentUserId);
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
    }
}