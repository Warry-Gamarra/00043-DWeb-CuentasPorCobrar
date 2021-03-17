using Domain.DTO;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class ConceptoPagoController : Controller
    {
        ProcesoModel procesoModel;
        private readonly ConceptoPagoModel _conceptoModel;

        public ConceptoPagoController()
        {
            procesoModel = new ProcesoModel();
            _conceptoModel = new ConceptoPagoModel();

        }

        [Route("configuracion/obligaciones-y-conceptos/{procesoId}/agregar-concepto/")]
        public ActionResult Create(int procesoId)
        {

            ViewBag.Title = "Registrar Conceptos";
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");
            ViewBag.ProcesoId = procesoId;

            return PartialView("_RegistrarConceptosPagoProceso", new RegistroConceptosProcesoViewModel() { MostrarFormulario = false });
        }


        [Route("configuracion/obligaciones-y-conceptos/{procesoId}/editar-concepto/{id}")]
        public ActionResult EditarConceptosPago(int id)
        {

            ViewBag.Title = "Registrar Conceptos";
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(), "Id", "NombreConcepto");

            return PartialView("_RegistrarConceptosPagoProceso", new RegistroConceptosProcesoViewModel());
        }


        //public ActionResult Grabar(int? id)
        //{
        //    ViewBag.Title = id.HasValue ? "Editar registro": "Nuevo registro";

        //    ViewBag.id = id ?? 0;

        //    return View();
        //}

        //[ChildActionOnly]
        //public ActionResult Create()
        //{
        //    ViewBag.Title = "Nuevo registro";

        //    Cargar_Listas();

        //    return PartialView("_MantenimientoConceptoPago");
        //}

        //[ChildActionOnly]
        //public ActionResult Edit(int id)
        //{
        //    ViewBag.Title = "Editar registro";

        //    Cargar_Listas();

        //    var model = conceptoPagoModel.Obtener_ConceptoPago(id);

        //    return PartialView("_MantenimientoConceptoPago", model);
        //}

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Save(RegistroConceptoPagoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _conceptoModel.Grabar_ConceptoPago(model, WebSecurity.CurrentUserId);

                if (!result.Value)
                {
                    ModelState.AddModelError("", result.Message);
                }
            }

            ViewBag.Title = model.I_ConcPagID.HasValue ? "Editar registro" : "Nuevo registro";

            Cargar_Listas();

            return JsonView(result, "_MantenimientoConceptoPago", model);
        }

        private JsonResult JsonView(Response result, string viewName, object model)
        {
            return Json(new { Result = result, View = RenderPartialView(viewName, model) });
        }

        private string RenderPartialView(string partialViewName, object model)
        {
            if (ControllerContext == null)
                return string.Empty;

            if (model == null)
                throw new ArgumentNullException("model");

            if (string.IsNullOrEmpty(partialViewName))
                throw new ArgumentNullException("partialViewName");

            ViewData.Model = model;

            using (var sw = new StringWriter())
            {
                var viewResult = ViewEngines.Engines.FindPartialView(ControllerContext, partialViewName);
                var viewContext = new ViewContext(ControllerContext, viewResult.View, ViewData, TempData, sw);
                viewResult.View.Render(viewContext, sw);
                return sw.GetStringBuilder().ToString();
            }
        }

        private void Cargar_Listas()
        {
            ViewBag.Lista_Combo_ConceptoPago = _conceptoModel.Listar_Combo_Concepto();

            ViewBag.Lista_Opciones_TipoAlumno = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno);

            ViewBag.Lista_Opciones_Grado = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado);

            ViewBag.Lista_Opciones_TipoObligacion = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoObligacion);

            ViewBag.Lista_Combo_Procesos = _conceptoModel.Listar_Combo_Procesos();

            ViewBag.Lista_Opciones_CampoCalculado = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CampoCalculado);

            ViewBag.Lista_Anios = procesoModel.Listar_Anios();

            ViewBag.Lista_Combo_Periodo = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Periodo);

            ViewBag.Lista_Combo_GrupoCodRc = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.GrupoCodRc);

            ViewBag.Lista_Combo_CodIngreso = _conceptoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CodIngreso);

        }

        //private static SelectList Lista_Vacia()
        //{
        //    var lista = new List<SelectListItem>();

        //    return new SelectList(lista, "Value", "Text");
        //}

    }
}