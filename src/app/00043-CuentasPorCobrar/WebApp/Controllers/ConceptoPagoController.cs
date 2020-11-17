using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;
using Domain.DTO;
using System.IO;

namespace WebApp.Controllers
{
    public class ConceptoPagoController : Controller
    {
        ConceptoPagoModel conceptoPagoModel;
        PeriodoModel periodoModel;

        public ConceptoPagoController()
        {
            conceptoPagoModel = new ConceptoPagoModel();
            periodoModel = new PeriodoModel();
        }

        public ActionResult Index()
        {
            ViewBag.Title = "Conceptos de Pago";

            var lista = conceptoPagoModel.Listar_ConceptoPagoPeriodo_Habilitados();

            return View(lista);
        }

        public ActionResult Grabar(int? id)
        {
            ViewBag.Title = id.HasValue ? "Editar registro": "Nuevo registro";

            ViewBag.id = id ?? 0;

            return View();
        }

        [ChildActionOnly]
        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo registro";

            Cargar_Listas();

            return PartialView("_MantenimientoConceptoPago");
        }

        [ChildActionOnly]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar registro";

            Cargar_Listas();

            var model = conceptoPagoModel.Obtener_ConceptoPagoPeriodo(id);

            return PartialView("_MantenimientoConceptoPago", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Save(MantenimientoConceptoPagoPeriodoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = conceptoPagoModel.Grabar_ConceptoPagoPeriodo(model, WebSecurity.CurrentUserId);

                if (!result.Value)
                {
                    ModelState.AddModelError("", result.Message);
                }
            }

            ViewBag.Title = model.I_ConcPagPerID.HasValue ? "Editar registro" : "Nuevo registro";

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
            ViewBag.Lista_Combo_ConceptoPago = conceptoPagoModel.Listar_Combo_ConceptoPago();

            ViewBag.Lista_Opciones_TipoAlumno = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno);

            ViewBag.Lista_Opciones_Grado = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado);

            ViewBag.Lista_Opciones_TipoObligacion = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoObligacion);

            ViewBag.Lista_Combo_CuotaPago = conceptoPagoModel.Listar_Combo_CuotaPago();

            ViewBag.Lista_Opciones_CampoCalculado = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CampoCalculado);

            ViewBag.Lista_Anios = periodoModel.Listar_Anios();

            ViewBag.Lista_Combo_Periodo = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Periodo);

            ViewBag.Lista_Combo_GrupoCodRc = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.GrupoCodRc);

            ViewBag.Lista_Combo_CodIngreso = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CodIngreso);

            ViewBag.Lista_Vacia = Lista_Vacia();
        }

        private static SelectList Lista_Vacia()
        {
            var lista = new List<SelectListItem>();

            return new SelectList(lista, "Value", "Text");
        }
    }
}