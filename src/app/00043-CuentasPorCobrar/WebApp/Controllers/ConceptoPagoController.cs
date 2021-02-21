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
    [Authorize]
    [Route("mantenimiento/conceptos-de-pago/{action}")]
    public class ConceptoPagoController : Controller
    {
        ConceptoPagoModel conceptoPagoModel;
        ProcesoModel procesoModel;

        public ConceptoPagoController()
        {
            conceptoPagoModel = new ConceptoPagoModel();
            procesoModel = new ProcesoModel();
        }

        [Route("mantenimiento/conceptos-de-pago")]
        public ActionResult Index()
        {
            ViewBag.Title = "Conceptos de Pago";

            var lista = conceptoPagoModel.Listar_CatalogoConceptos();

            return View(lista);
        }

        [Route("mantenimiento/conceptos-de-pago/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo concepto de pago";


            return PartialView("_RegistrarConcepto", new CatalogoConceptosRegistroViewModel());
        }

        [Route("mantenimiento/conceptos-de-pago/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "editar concepto de pago";


            return PartialView("_RegistrarConcepto", conceptoPagoModel.ObtenerConcepto(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = conceptoPagoModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "EntidadFinanciera"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(CatalogoConceptosRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = conceptoPagoModel.Save(model, WebSecurity.CurrentUserId);
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

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos. " + details);
            }
            return PartialView("_MsgPartialWR", result);
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

        //[HttpPost]
        //[ValidateAntiForgeryToken]
        //public JsonResult Save(MantenimientoConceptoPagoViewModel model)
        //{
        //    Response result = new Response();

        //    if (ModelState.IsValid)
        //    {
        //        result = conceptoPagoModel.Grabar_ConceptoPago(model, WebSecurity.CurrentUserId);

        //        if (!result.Value)
        //        {
        //            ModelState.AddModelError("", result.Message);
        //        }
        //    }

        //    ViewBag.Title = model.I_ConcPagID.HasValue ? "Editar registro" : "Nuevo registro";

        //    Cargar_Listas();

        //    return JsonView(result, "_MantenimientoConceptoPago", model);
        //}

        //private JsonResult JsonView(Response result, string viewName, object model)
        //{
        //    return Json(new { Result = result, View = RenderPartialView(viewName, model) });
        //}

        //private string RenderPartialView(string partialViewName, object model)
        //{
        //    if (ControllerContext == null)
        //        return string.Empty;

        //    if (model == null)
        //        throw new ArgumentNullException("model");

        //    if (string.IsNullOrEmpty(partialViewName))
        //        throw new ArgumentNullException("partialViewName");

        //    ViewData.Model = model;

        //    using (var sw = new StringWriter())
        //    {
        //        var viewResult = ViewEngines.Engines.FindPartialView(ControllerContext, partialViewName);
        //        var viewContext = new ViewContext(ControllerContext, viewResult.View, ViewData, TempData, sw);
        //        viewResult.View.Render(viewContext, sw);
        //        return sw.GetStringBuilder().ToString();
        //    }
        //}

        //private void Cargar_Listas()
        //{
        //    ViewBag.Lista_Combo_ConceptoPago = conceptoPagoModel.Listar_Combo_Concepto();

        //    ViewBag.Lista_Opciones_TipoAlumno = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno);

        //    ViewBag.Lista_Opciones_Grado = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado);

        //    ViewBag.Lista_Opciones_TipoObligacion = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoObligacion);

        //    ViewBag.Lista_Combo_Procesos = conceptoPagoModel.Listar_Combo_Procesos();

        //    ViewBag.Lista_Opciones_CampoCalculado = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CampoCalculado);

        //    ViewBag.Lista_Anios = procesoModel.Listar_Anios();

        //    ViewBag.Lista_Combo_Periodo = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Periodo);

        //    ViewBag.Lista_Combo_GrupoCodRc = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.GrupoCodRc);

        //    ViewBag.Lista_Combo_CodIngreso = conceptoPagoModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CodIngreso);

        //    ViewBag.Lista_Vacia = Lista_Vacia();
        //}

        //private static SelectList Lista_Vacia()
        //{
        //    var lista = new List<SelectListItem>();

        //    return new SelectList(lista, "Value", "Text");
        //}
    }
}