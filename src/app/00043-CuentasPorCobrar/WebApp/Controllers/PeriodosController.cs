using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class PeriodosController : Controller
    {
        PeriodoModel periodoModel;

        public PeriodosController()
        {
            periodoModel = new PeriodoModel();
        } 

        // GET: Periodos_Academicos
        public ActionResult Index()
        {
            ViewBag.Title = "Desc. Cuota de Pago";

            var lista = periodoModel.Listar_Periodos_Habilitados();

            return View(lista);
        }

        // GET: Periodos_Academicos/Create
        public ActionResult Create()
        {
            ViewBag.Lista_Cuota_Pago = periodoModel.Listar_Cuota_Pago_Habilitadas();

            ViewBag.Title = "Nuevo registro";

            return PartialView("_Create");
        }

        // POST: Periodos_Academicos/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(NuevoPeriodoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = periodoModel.Grabar_Periodo(model);
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

        //// GET: Periodos_Academicos/Edit/5
        //public ActionResult Edit(int id)
        //{
        //    var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

        //    var model = lista.FirstOrDefault(x => x.Id == id);

        //    return View(model);
        //}

        //// POST: Periodos_Academicos/Edit/5
        //[HttpPost]
        //public ActionResult Edit(int id, PeriodoViewModel model)
        //{
        //    try
        //    {
        //        var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

        //        var old_model = lista.FirstOrDefault(x => x.Id == id);


        //        old_model.Fecha_Vencimiento = model.Fecha_Vencimiento;

        //        return RedirectToAction("Index");
        //    }
        //    catch
        //    {
        //        return View();
        //    }
        //}

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