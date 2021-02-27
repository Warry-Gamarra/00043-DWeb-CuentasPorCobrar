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

            var lista = procesoModel.Listar_Procesos();

            return View(lista);
        }

        [Route("configuracion/obligaciones-y-conceptos")]
        public ActionResult Obligaciones(int? anio, int? grado)
        {
            ViewBag.Title = "Obligaciones y conceptos";

            anio = anio ?? DateTime.Now.Year;
            grado = grado ?? 4;

            ViewBag.Anios = new SelectList(_selectModel.GetAnios(1990), "Value", "TextDisplay", anio);
            ViewBag.Grados = new SelectList(_selectModel.GetGradosAcademicos(), "Value", "TextDisplay", grado);

            ViewBag.Message = TempData["Message"];

            return View("Obligaciones", procesoModel.ObtenerCategoriasPorAnioGradoAcad(anio.Value, grado.Value));
        }

        [HttpPost]
        public ActionResult CategoriasEstado(FormCollection formCollection)
        {
            int anio = int.Parse(formCollection["inputAnio"]);
            int gradoId = int.Parse(formCollection["inputGrado"]);

            return PartialView("_CategoriasEstado", procesoModel.ObtenerCategoriasPorAnioGradoAcad(anio, gradoId));
        }


        [Route("configuracion/obligaciones-y-conceptos/{categoriaId}/{aaaa}/{grado}")]
        public ActionResult ProcesosCategoria(int categoriaId, int? aaaa, int? grado)
        {

            if (aaaa.HasValue && grado.HasValue)
            {
                var categoria = _categoriaPagoModel.Find().Find(x => x.Id == categoriaId);

                ViewBag.Anio = aaaa;
                ViewBag.PeriodoId = grado;
                ViewBag.Title = $"{aaaa.ToString()} - {categoria.Nombre}";

                var model = new ProcesoCategoriaViewModel()
                {
                    AnioProc = aaaa.Value,
                    Categoria = categoria,
                    Procesos = procesoModel.Listar_Procesos()
                };

                return View("ObligacionesProcesosAnio", model);
            }
            else
            {
                TempData["Message"] = "Seleccionar <strong>año, periodo académico y categoría </strong> para configurar las obligaciones";

                return RedirectToAction("Obligaciones");
            }
        }

        public ActionResult AgregarProcesosObligaciones(int catId, int anio)
        {
            ViewBag.Title = "Agregar obligación";

            ViewBag.Lista_CtaDepoHabilitadas = new List<SelectViewModel>();
            ViewBag.Lista_CtaDepoProceso = new List<SelectViewModel>();
            ViewBag.Periodos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay");
            ViewBag.CtasDeposito = new SelectList(_cuentasDeposito.Find(), "Id", "NumeroCuenta");
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");
            ViewBag.Dependencias = new SelectList(_selectModel.GetDependencias(), "Value", "TextDisplay", _dependenciaUsuarioId);

            var model = procesoModel.InitProcesoCategoria(catId, anio);

            return PartialView("_RegistrarProcesoObligacionCocepto", model);
        }






        [Route("configuracion/tasas-y-servicios")]
        public ActionResult Tasas()
        {
            ViewBag.Title = "Tasas y Servicios";

            var lista = procesoModel.Listar_Tasas();
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");
            ViewBag.Dependencias = new SelectList(_selectModel.GetDependencias(), "Value", "TextDisplay", _dependenciaUsuarioId);

            return View("Tasas", lista);
        }

        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo registro";

            Cargar_Listas();

            ViewBag.Lista_CtaDepoHabilitadas = new List<SelectViewModel>();

            ViewBag.Lista_CtaDepoProceso = new List<SelectViewModel>();

            return PartialView("_MantenimientoProceso");
        }




        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar registro";

            Cargar_Listas();

            var model = procesoModel.Obtener_Proceso(id);

            ViewBag.Lista_CtaDepoHabilitadas = procesoModel.Listar_Combo_CtaDepositoHabilitadas(model.I_CatPagoID);

            ViewBag.Lista_CtaDepoProceso = procesoModel.Listar_Combo_CtasDepoProceso(id);

            return PartialView("_MantenimientoProceso", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(MantenimientoProcesoViewModel model)
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

        private void Cargar_Listas()
        {
            ViewBag.Lista_Anios = procesoModel.Listar_Anios();
        }
    }
}