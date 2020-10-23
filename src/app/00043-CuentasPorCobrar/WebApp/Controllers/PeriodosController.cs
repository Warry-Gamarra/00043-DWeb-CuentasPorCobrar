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
    public class PeriodosController : Controller
    {
        PeriodoModel periodoModel;

        public PeriodosController()
        {
            periodoModel = new PeriodoModel();
        } 

        public ActionResult Index()
        {
            ViewBag.Title = "Desc. Cuota de Pago";

            var lista = periodoModel.Listar_Periodos_Habilitados();

            return View(lista);
        }

        public ActionResult Create()
        {
            ViewBag.Lista_Tipo_Periodo = periodoModel.Listar_Tipo_Periodo_Habilitados();

            ViewBag.Lista_Anios = periodoModel.Listar_Anios();

            ViewBag.Title = "Nuevo registro";

            return PartialView("_MantenimientoPeriodo");
        }

        public ActionResult Edit(int id)
        {
            ViewBag.Lista_Tipo_Periodo = periodoModel.Listar_Tipo_Periodo_Habilitados();

            ViewBag.Lista_Anios = periodoModel.Listar_Anios();

            ViewBag.Title = "Editar registro";

            var model = periodoModel.Obtener_Periodo(id);

            return PartialView("_MantenimientoPeriodo", model);
        }

        // POST: Periodos_Academicos/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(MantenimientoPeriodoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = periodoModel.Grabar_Periodo(model, WebSecurity.CurrentUserId);
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
        
        //// GET: Periodos_Academicos/Delete/5
        //public ActionResult Delete(int id)
        //{
        //    var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

        //    var model = lista.FirstOrDefault(x => x.Id == id);

        //    return View(model);
        //}

        //// POST: Periodos_Academicos/Delete/5
        //[HttpPost]
        //public ActionResult Delete(int id, FormCollection collection)
        //{
        //    try
        //    {
        //        var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

        //        lista.RemoveAll(x => x.Id == id);

        //        return RedirectToAction("Index");
        //    }
        //    catch
        //    {
        //        return View();
        //    }
        //}
    }
}