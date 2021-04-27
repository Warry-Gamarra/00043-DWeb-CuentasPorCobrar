using Domain.Entities;
using Domain.Helpers;
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
    public class EstructuraArchivoController : Controller
    {
        private readonly EntidadFinancieraModel _entidadFinanciera;
        private readonly EstructuraArchivoModel _estructuraArchivo;

        public EstructuraArchivoController()
        {
            _entidadFinanciera = new EntidadFinancieraModel();
            _estructuraArchivo = new EstructuraArchivoModel();
        }

        // GET: EstructuraArchivo
        [Route("mantenimiento/archivos-intercambio")]
        public ActionResult Index()
        {
            ViewBag.Title = "Archivos de intercambio";
            var model = _estructuraArchivo.ObtenerArchivoIntercambio();

            return View(model);
        }

        [Route("mantenimiento/archivos-intercambio/Banco/{Id}")]
        public ActionResult Banco(int Id)
        {
            ViewBag.Title = "Archivos de intercambio: " + _entidadFinanciera.Find(Id).NombreEntidad.ToUpper();
            ViewBag.BancoId = Id;
            var model = _estructuraArchivo.ObtenerArchivoIntercambioEntidadFinanciera(Id);

            return View(model);
        }


        [Route("mantenimiento/archivos-intercambio/{banco}/nuevo")]
        public ActionResult Create(int banco = 0)
        {
            ViewBag.Title = "Agregar archivo de intercambio";
            if (banco == 0)
            {
                ViewBag.EntidadesFinancieras = new SelectList(_entidadFinanciera.Find(enabled: true), "Id", "NombreEntidad");
            }
            else
            {
                ViewBag.EntidadesFinancieras = new SelectList(_entidadFinanciera.Find().Where(x => x.Id == banco), "Id", "NombreEntidad");
            }
            ViewBag.TiposArchivo = _estructuraArchivo.ObtenerTiposArchivo();

            return PartialView("_RegistroArchivoIntercambio", new RegistrarArchivoIntercambioViewModel() { EntiFinanId = banco });
        }

        [Route("mantenimiento/archivos-intercambio/{banco}/editar")]
        public ActionResult Edit(int id, int banco = 0)
        {
            ViewBag.Title = "Editar archivo de intercambio";

            var model = _estructuraArchivo.ObtenerArchivoIntercambio(id);
            ViewBag.EntidadesFinancieras = new SelectList(_entidadFinanciera.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.TiposArchivo = _estructuraArchivo.ObtenerTiposArchivo();

            return PartialView("_RegistroArchivoIntercambio", model);
        }

        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _estructuraArchivo.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "EstructuraArchivo"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult Save(RegistrarArchivoIntercambioViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _estructuraArchivo.Save(model, WebSecurity.CurrentUserId);
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



        [Route("mantenimiento/campos-tabla")]
        public ActionResult CamposTabla()
        {
            ViewBag.Title = "Campos de tabla";
            var model = _estructuraArchivo.ObtenerCamposTabla(null);

            return View(model);
        }


        [Route("mantenimiento/campos-tabla/agregar")]
        public ActionResult CampoCreate()
        {
            ViewBag.Title = "Agregar campo de pago";

            ViewBag.Tablas = new SelectList(_estructuraArchivo.ObtenerTablasBD(), "Value", "TextDisplay");
            ViewBag.ColumnasTabla = new SelectList(new List<SelectViewModel>());
            ViewBag.TipoArchivo = _estructuraArchivo.ObtenerTiposArchivo();

            return PartialView("_RegistroCampoTabla", new CamposTablaViewModel());
        }


        [Route("mantenimiento/campos-tabla/{campoId}/editar")]
        public ActionResult CampoEdit(int campoId)
        {
            ViewBag.Title = "Editar campos de pago";

            CamposTablaViewModel model = _estructuraArchivo.ObtenerCampoTabla(campoId);

            ViewBag.Tablas = new SelectList(_estructuraArchivo.ObtenerTablasBD(), "Value", "TextDisplay", model.NombreTabla);
            ViewBag.ColumnasTabla = new SelectList(_estructuraArchivo.ObtenerColumnasTabla(model.NombreTabla), "Value", "TextDisplay");
            ViewBag.TipoArchivo = _estructuraArchivo.ObtenerTiposArchivo();

            return PartialView("_RegistroCampoTabla", model);
        }

        [HttpPost]
        public JsonResult CampoChangeState(int RowID, bool B_habilitado)
        {
            var result = _estructuraArchivo.CampoChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("CampoChangeState", "EstructuraArchivo"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult CampoSave(CamposTablaViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _estructuraArchivo.GrabarCampoTabla(model, WebSecurity.CurrentUserId);
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




        [Route("mantenimiento/archivos-intercambio/registro-estructura/{id}")]
        public ActionResult RegistrarSecciones(int id = 0)
        {
            ViewBag.Title = "Agregar estructura de archivo";
            ViewBag.EntidadesFinancieras = new SelectList(_entidadFinanciera.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.TiposArchivo = _estructuraArchivo.ObtenerTiposArchivo();

            return PartialView("_RegistroEstructuraArchivo", new List<SeccionArchivoViewModel>());
        }

        [HttpPost]
        public ActionResult SeccionesColumnasSave(SeccionArchivoViewModel[] model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _estructuraArchivo.GrabarSeccionesArchivo(model.ToList(), WebSecurity.CurrentUserId);
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