using Domain.Helpers;
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
        private readonly SelectModel _selectModel;
        private readonly ConceptoPagoModel _conceptoModel;
        private readonly CategoriaPagoModel _categoriaPagoModel;
        private readonly CuentaDepositoModel _cuentasDeposito;

        public ProcesosController()
        {
            procesoModel = new ProcesoModel();
            _selectModel = new SelectModel();
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

            var lista = procesoModel.Listar_Procesos(DateTime.Now.Year);

            return View(lista);
        }

        [Route("configuracion/cuotas-de-pago-y-conceptos")]
        public ActionResult Obligaciones(int? anio, int? grado)
        {
            ViewBag.Title = "Cuotas de pago y conceptos";

            anio = anio ?? DateTime.Now.Year;
            grado = grado ?? 4;

            ViewBag.Anios = new SelectList(_selectModel.GetAnios(1990), "Value", "TextDisplay", anio);
            ViewBag.AnioSelect = anio;

            ViewBag.Message = TempData["Message"];

            return View("Obligaciones", procesoModel.Listar_Procesos(anio.Value));
        }

        [Route("configuracion/cuotas-de-pago-y-conceptos/{anio}/nueva-cuota-pago")]
        public ActionResult CreateCuotaPago(int anio)
        {
            ViewBag.Title = "Nueva Cuota de Pago";

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find(TipoObligacion.Matricula), "Id", "Nombre");
            ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay", null);
            ViewBag.CtasDeposito = new SelectList(new List<SelectViewModel>());

            return PartialView("_RegistrarProcesoObligacion", new RegistroProcesoViewModel()
            {
                Anio = anio,
                CtasBcoComercio = _cuentasDeposito.Find().Where(x => x.EntidadFinancieraId == Constantes.BANCO_COMERCIO_ID).Select(x => x.Id.Value).ToArray()
            });
        }


        [Route("configuracion/cuotas-de-pago-y-conceptos/{id}/editar")]
        public ActionResult EditCuotaPago(int id)
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


        [Route("configuracion/tasas-y-servicios")]
        public ActionResult Tasas()
        {
            ViewBag.Title = "Tasas y Servicios";

            var lista = procesoModel.Listar_Tasas();

            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(TipoObligacion.OtrosPagos), "Id", "NombreConcepto");
            ViewBag.Dependencias = new SelectList(_selectModel.GetDependencias(), "Value", "TextDisplay", _dependenciaUsuarioId);

            return View("Tasas", lista);
        }

        [Route("configuracion/tasas-y-servicios/habilitar-grupo")]
        public ActionResult CreateGrupoTasa()
        {
            ViewBag.Title = "Nueva Cuota de Pago";

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find(TipoObligacion.OtrosPagos), "Id", "Nombre");
            ViewBag.CtasDeposito = new SelectList(new List<SelectViewModel>());

            return PartialView("_RegistrarProcesoTasa", new RegistroProcesoViewModel()
            {
                CtasBcoComercio = _cuentasDeposito.Find().Where(x => x.EntidadFinancieraId == Constantes.BANCO_COMERCIO_ID).Select(x => x.Id.Value).ToArray()
            });
        }


        [Route("configuracion/tasas-y-servicios/{id}/editar")]
        public ActionResult EditGrupoTasa(int id)
        {
            ViewBag.Title = "Editar Cuota de Pago";

            RegistroProcesoViewModel model = procesoModel.Obtener_Proceso(id);

            var ctasCategoria = new List<SelectViewModel>();

            foreach (var item in procesoModel.Listar_Combo_CtaDepositoHabilitadas(model.CategoriaId.Value).Select(x => x.ItemsGroup))
            {
                ctasCategoria.AddRange(item);
            }

            ViewBag.Categorias = new SelectList(_categoriaPagoModel.Find().Where(x => x.Id == model.CategoriaId.Value), "Id", "Nombre");
            ViewBag.CtasDeposito = new SelectList(ctasCategoria, "Value", "TextDisplay", "NameGroup", model.CtaDepositoID, null);

            return PartialView("_RegistrarProcesoTasa", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistroProcesoViewModel model, DateTime txtFecVencto)
        {
            Response result = new Response();

            model.FecVencto = txtFecVencto;

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


        [Route("configuracion/cuotas-de-pago-y-conceptos/{procesoId}/conceptos-de-pago")]
        public ActionResult VerConceptos(int procesoId)
        {
            ViewBag.Title = procesoModel.Obtener_Proceso(procesoId).DescProceso;
            ViewBag.ProcesoId = procesoId;

            var model = procesoModel.ObtenerConceptosProceso(procesoId);

            return PartialView("_ListadoConceptosProceso", model);
        }


        [Route("configuracion/tasas-y-servicios/{procesoId}/tasas")]
        public ActionResult VerTasas(int procesoId)
        {
            ViewBag.ProcesoId = procesoId;

            var model = procesoModel.ObtenerConceptosProceso(procesoId);

            return PartialView("_ListadoTasasProcesoGrupos", model);
        }


        public ActionResult BuscarTasas(int? concepto, int? dependencia)
        {
            var model = procesoModel.ObtenerConceptosTipoObligacionHabilitados(null, TipoObligacion.OtrosPagos);

            return PartialView("_ListadoTasasProcesoBusqueda", model);
        }
    }
}