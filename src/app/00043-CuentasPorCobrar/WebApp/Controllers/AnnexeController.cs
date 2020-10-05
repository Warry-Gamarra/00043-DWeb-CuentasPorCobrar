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
    [Route("Mantenimiento/dependencia/{action}")]
    public class AnnexeController : Controller
    {
        public readonly AnnexeModel _annexeModel;
        public AnnexeController()
        {
            _annexeModel = new AnnexeModel();
        }

        [HttpGet]
        public ActionResult Index()
        {
            ViewBag.Title = "Dependencias";
            var model = _annexeModel.Find();

            return View(model);
        }

        [Route("Mantenimiento/dependencia/nuevo")]
        [HttpGet]
        public ActionResult New()
        {
            var model = _annexeModel.Find();

            return PartialView(model);
        }

        [Route("Mantenimiento/dependencia/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            var model = _annexeModel.Find();

            return PartialView(model);
        }

        [HttpPost]
        public ActionResult Save(AnnexeViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _annexeModel.Save(model, WebSecurity.CurrentUserId);
            }
            else
            {
                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos");
            }
            return PartialView(result);
        }

    }
}