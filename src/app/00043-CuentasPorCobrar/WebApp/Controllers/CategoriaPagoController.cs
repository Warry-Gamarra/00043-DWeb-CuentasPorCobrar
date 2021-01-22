using Domain.DTO;
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
    public class CategoriaPagoController : Controller
    {
        private readonly CategoriaPagoModel _categoriaPago;

        public CategoriaPagoController()
        {
            _categoriaPago = new CategoriaPagoModel();
        }

        [Route("mantenimiento/categorias-de-pago")]
        public ActionResult Index()
        {
            ViewBag.Title = "Categorías de Pago";
            var model = new List<CategoriaPagoViewModel>();
            return View(model);
        }


        [Route("mantenimiento/categorias-de-pago/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Categoría de Pago";

            return PartialView("_RegistrarCategoriaPago", new CategoriaPagoRegistroViewModel());
        }

        [Route("mantenimiento/categorias-de-pago/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Clasificador";

            return PartialView("_RegistrarEntidadFinanciera", _categoriaPago.Find(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _categoriaPago.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "EntidadFinanciera"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(CategoriaPagoRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _categoriaPago.Save(model, WebSecurity.CurrentUserId);
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

    }
}