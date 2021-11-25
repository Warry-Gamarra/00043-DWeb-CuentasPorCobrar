using Domain.Helpers;
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
        private readonly ProcesoModel _procesoModel;
        private readonly ConceptoPagoModel _conceptoPagoModel;
        private readonly ConceptoModel _conceptoModel;
        private readonly SelectModel _selectModel;

        public ConceptoPagoController()
        {
            _procesoModel = new ProcesoModel();
            _conceptoPagoModel = new ConceptoPagoModel();
            _conceptoModel = new ConceptoModel();
            _selectModel = new SelectModel();
        }

        [Route("configuracion/cuotas-de-pago-y-conceptos/{procesoId}/agregar-concepto-obligacion/")]
        public ActionResult CreateObligacion(int procesoId)
        {
            ViewBag.Title = "Registrar Concepto";
            ViewBag.Conceptos = new SelectList(_conceptoModel.Listar_CatalogoConceptos(TipoPago.Obligacion), "Id", "NombreConcepto");

            var model = new RegistroConceptosProcesoViewModel(procesoId, _conceptoPagoModel)
            {
                MostrarFormulario = false
            };

            return PartialView("_RegistrarConceptosPagoProceso", model);
        }


        [Route("configuracion/cuotas-de-pago-y-conceptos/{procesoId}/editar-concepto-obligacion/{id}")]
        public ActionResult EditObligacion(int procesoId, int id)
        {
            ViewBag.Title = "Editar Concepto";
            var model = _conceptoPagoModel.ObtenerConceptoPagoProceso(procesoId, id);

            return PartialView("_RegistrarConceptosPagoProceso", model);
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


        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _conceptoPagoModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "ConceptoPago"));

            return Json(result, JsonRequestBehavior.AllowGet);
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

            ViewBag.Lista_Opciones_TipoAlumno = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno);

            ViewBag.Lista_Opciones_Grado = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado);

            ViewBag.Lista_Opciones_TipoObligacion = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoObligacion);

            ViewBag.Lista_Combo_Procesos = _conceptoPagoModel.Listar_Combo_Procesos();

            ViewBag.Lista_Opciones_CampoCalculado = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CampoCalculado);

            ViewBag.Lista_Anios = _procesoModel.Listar_Anios();

            ViewBag.Lista_Combo_Periodo = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Periodo);

            ViewBag.Lista_Combo_GrupoCodRc = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.GrupoCodRc);

            ViewBag.Lista_Combo_CodIngreso = _selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CodIngreso);

        }
    }
}