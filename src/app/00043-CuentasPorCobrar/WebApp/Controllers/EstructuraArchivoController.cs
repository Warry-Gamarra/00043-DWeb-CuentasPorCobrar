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
    [Authorize(Roles = RoleNames.ADMINISTRADOR)]
    public class EstructuraArchivoController : Controller
    {
        private readonly EntidadRecaudadoraModel _entidadFinanciera;
        private readonly EstructuraArchivoModel _estructuraArchivo;

        public EstructuraArchivoController()
        {
            _entidadFinanciera = new EntidadRecaudadoraModel();
            _estructuraArchivo = new EstructuraArchivoModel();
        }

        #region archivos-intercambio

        [Route("mantenimiento/archivos-intercambio")]
        public ActionResult Index()
        {
            ViewBag.Title = "Archivos de intercambio";
            var model = _estructuraArchivo.ObtenerArchivoIntercambio();

            return View(model);
        }

        [Route("mantenimiento/archivos-intercambio/Banco/{Id}")]
        public ActionResult Banco(int id)
        {
            ViewBag.Title = "Archivos de intercambio: " + _entidadFinanciera.Find(id).NombreEntidad.ToUpper();
            ViewBag.BancoId = id;
            var model = _estructuraArchivo.ObtenerArchivoIntercambioEntidadFinanciera(id);

            return View(model);
        }


        [Route("mantenimiento/archivos-intercambio/Banco/{banco}/nuevo")]
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

        [Route("mantenimiento/archivos-intercambio/Banco/{banco}/editar")]
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


        #endregion

        #region Campos de tabla
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

        #endregion


        #region secciones estructura archivo

        [Route("mantenimiento/archivos-intercambio/ver-estructura/{id}")]
        public ActionResult VerEstructuraArchivoBanco(int id)
        {
            ViewBag.Title = "Estructura de archivo";
            var model = _estructuraArchivo.ObtenerEstructuraArchivo(id);

            return PartialView("_VerEstructuraArchivo", model);
        }

        [Route("mantenimiento/archivos-intercambio/{archivoId}/seccion-archivo")]
        public ActionResult SeccionesEstructuraArchivo(int archivoId, TipoSeccionArchivo tipoSeccion = TipoSeccionArchivo.Cabecera_Resumen)
        {
            var estructura = _estructuraArchivo.ObtenerArchivoIntercambio(archivoId);

            ViewBag.Banco = estructura.EntiFinanNom;
            ViewBag.BancoId = estructura.EntiFinanId;
            ViewBag.TipoSeccion = tipoSeccion.ToString();
            ViewBag.Title = estructura.TipoArchivo.ToString().Replace('_', ' ');

            var model = _estructuraArchivo.ObtenerEstructuraArchivo(archivoId);

            return View(model);
        }

        [Route("mantenimiento/archivos-intercambio/{archivoId}/seccion-archivo/agregar")]
        public ActionResult AgregarSeccionArchivo(int archivoId, TipoSeccionArchivo tipoSeccion)
        {
            ViewBag.Title = "Agregar " + tipoSeccion.ToString().Replace('_', ' ');
            var model = _estructuraArchivo.SeccionesArchivoInit(archivoId).Find(x => x.TipoSeccion == tipoSeccion);

            return PartialView("_RegistroSeccionArchivo", model);
        }

        [Route("mantenimiento/archivos-intercambio/{archivoId}/seccion-archivo/editar")]
        public ActionResult EditarSeccionArchivo(int archivoId, int id)
        {
            ViewBag.Title = "Editar sección de archivo";
            var model = _estructuraArchivo.ObtenerSeccionArchivo(id);

            return PartialView("_RegistroSeccionArchivo", model);
        }

        [HttpPost]
        public ActionResult SeccionArchivoSave(SeccionArchivoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _estructuraArchivo.GrabarSeccionArchivo(model, WebSecurity.CurrentUserId);
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

        #endregion


        #region columnas estructura archivo

        [Route("mantenimiento/archivos-intercambio/{archivoId}/seccion-archivo/{seccionId}/columnas")]
        public ActionResult ColumnasSeccionEstructuraArchivo(int archivoId, int seccionId)
        {
            ViewBag.Title = "Agregar estructura de archivo";
            var model = _estructuraArchivo.ObtenerEstructuraArchivo(seccionId);

            return PartialView(model);
        }

        [Route("mantenimiento/archivos-intercambio/{archivoId}/seccion-archivo/{seccionId}/columnas/agregar")]
        public ActionResult AgregarColumnasSeccion(int archivoId, int seccionId)
        {
            ViewBag.Title = "Agregar columnas";
            var seccionArchivo = _estructuraArchivo.ObtenerSeccionArchivo(seccionId);
            ViewBag.CamposTablas = new SelectList(_estructuraArchivo.ObtenerCamposTabla(seccionArchivo.TipoArchivoEnt), "CampoId", "DescCampo");

            var model = _estructuraArchivo.ColumnaSeccionArchivoInit(seccionId);

            return PartialView("_RegistroColumnaSeccion", model);
        }

        [Route("mantenimiento/archivos-intercambio/{archivoId}/seccion-archivo/{seccionId}/columnas/editar/{id}")]
        public ActionResult EditarColumnasSeccion(int archivoId, int seccionId, int id)
        {
            ViewBag.Title = "Editar columna";
            var seccionArchivo = _estructuraArchivo.ObtenerSeccionArchivo(seccionId);
            ViewBag.CamposTablas = new SelectList(_estructuraArchivo.ObtenerCamposTabla(seccionArchivo.TipoArchivoEnt), "CampoId", "DescCampo");

            var model = _estructuraArchivo.ObtenerColumnaSeccionArchivo(seccionId, id);

            return PartialView("_RegistroColumnaSeccion", model);
        }


        [HttpPost]
        public ActionResult ColumnasSeccionSave(ColumnaSeccionViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _estructuraArchivo.GrabarColumnaSeccionArchivo(model, WebSecurity.CurrentUserId);
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

        #endregion
    }
}