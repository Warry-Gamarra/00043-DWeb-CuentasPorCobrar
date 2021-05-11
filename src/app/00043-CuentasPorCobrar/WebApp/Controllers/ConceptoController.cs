using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;
using Domain.Helpers;
using System.IO;

namespace WebApp.Controllers
{
    [Authorize]
    [Route("mantenimiento/conceptos-de-pago/{action}")]
    public class ConceptoController : Controller
    {
        private readonly ConceptoModel conceptoModel;
        private readonly ProcesoModel procesoModel;
        private readonly SelectModel selectModel;

        public ConceptoController()
        {
            conceptoModel = new ConceptoModel();
            procesoModel = new ProcesoModel();
            selectModel = new SelectModel();
        }

        [Route("mantenimiento/conceptos-de-pago")]
        public ActionResult Index()
        {
            ViewBag.Title = "Conceptos de Pago";

            var lista = conceptoModel.Listar_CatalogoConceptos();

            return View(lista);
        }

        [Route("mantenimiento/conceptos-de-pago/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo concepto de pago";
            Cargar_Listas();
            ViewBag.CalculadoVisible = "none";

            return PartialView("_RegistrarConcepto", new CatalogoConceptosRegistroViewModel());
        }

        [Route("mantenimiento/conceptos-de-pago/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar concepto de pago";
            Cargar_Listas();

            CatalogoConceptosRegistroViewModel model = conceptoModel.ObtenerConcepto(id);

            ViewBag.CalculadoVisible = model.Calculado ? "block" : "none";

            return PartialView("_RegistrarConcepto", model);
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = conceptoModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "Concepto"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(CatalogoConceptosRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = conceptoModel.Save(model, WebSecurity.CurrentUserId);
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


        private void Cargar_Listas()
        {
            ViewBag.Lista_Combo_ConceptoPago = conceptoModel.Listar_Combo_Concepto();

            ViewBag.Lista_Opciones_TipoAlumno = selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoAlumno);

            ViewBag.Lista_Opciones_Grado = selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Grado);

            ViewBag.Lista_Opciones_TipoObligacion = selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.TipoObligacion);

            ViewBag.Lista_Opciones_CampoCalculado = selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CampoCalculado);

            ViewBag.Lista_Anios = procesoModel.Listar_Anios();

            ViewBag.Lista_Combo_Periodo = selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.Periodo);

            ViewBag.Lista_Combo_GrupoCodRc = new SelectList(selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.GrupoCodRc), "Value", "TextDisplay");

            ViewBag.Lista_Combo_CodIngreso = selectModel.Listar_Combo_CatalogoOpcion_X_Parametro(Parametro.CodIngreso);

        }
    }
}