﻿using ClosedXML.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize(Roles = "Administrador, Consulta")]
    public class EstudiantesController : Controller
    {
        private readonly EstudianteModel _seleccionarArchivoModel;

        IGeneralServiceFacade generalServiceFacade;
        ICatalogoServiceFacade catalogoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IMatriculaServiceFacade matriculaServiceFacade;

        IReportePregradoServiceFacade reportePregradoServiceFacade;
        IReportePosgradoServiceFacade reportePosgradoServiceFacade;

        public EstudiantesController()
        {
            _seleccionarArchivoModel = new EstudianteModel();
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
            matriculaServiceFacade = new MatriculaServiceFacade();

            reportePregradoServiceFacade = new ReportePregradoServiceFacade();
            reportePosgradoServiceFacade = new ReportePosgradoServiceFacade();
        }

        [Authorize(Roles = "Administrador")]
        [Route("operaciones/cargar-estudiantes")]
        public ActionResult Index()
        {
            ViewBag.Title = "Carga de Alumnos";

            return View();
        }

        [Authorize(Roles = "Administrador")]
        [Route("operaciones/cargar-aptos-pregrado")]
        public ActionResult CargarArchivoMatriculaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Authorize(Roles = "Administrador")]
        [Route("operaciones/cargar-aptos-posgrado")]
        public ActionResult CargarArchivoMatriculaPosgrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }


        [Authorize(Roles = "Administrador")]
        [Route("operaciones/cargar-multas-pregrado")]
        public ActionResult CargarArchivoMultaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.MultaNoVotar);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Authorize(Roles = "Administrador")]
        [HttpPost]
        public ActionResult CargarArchivoMatricula(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            var result = _seleccionarArchivoModel.CargarMatricula(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            var response = Mapper.DataMatriculaResponse_To_Response(result);

            Session["MATRICULA_RESPONSE"] = result.DataMatriculasObs;

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [Authorize(Roles = "Administrador")]
        public ActionResult DescargarRegistrosObservados()
        {
            if (Session["MATRICULA_RESPONSE"] == null)
                return  RedirectToAction("cargar-estudiantes", "operaciones");

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Students");
                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Cod_rc";
                worksheet.Cell(currentRow, 2).Value = "Cod_alu";
                worksheet.Cell(currentRow, 3).Value = "Año";
                worksheet.Cell(currentRow, 4).Value = "P";
                worksheet.Cell(currentRow, 5).Value = "Est_mat";
                worksheet.Cell(currentRow, 6).Value = "Nivel";
                worksheet.Cell(currentRow, 7).Value = "Es_ingresa";
                worksheet.Cell(currentRow, 8).Value = "Cred_desap";
                worksheet.Cell(currentRow, 9).Value = "Observación";
                worksheet.Cell(currentRow, 10).Value = "Act_Obl";
                
                #endregion

                #region Body
                foreach (var item in (List<Domain.Entities.MatriculaObsEntity>)Session["MATRICULA_RESPONSE"])
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.C_CodRC);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_CodAlu);
                    worksheet.Cell(currentRow, 3).Value = item.I_Anio;
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_Periodo);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.C_EstMat);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.C_Ciclo);
                    worksheet.Cell(currentRow, 7).Value = item.B_Ingresante.HasValue ? (item.B_Ingresante.Value ? "T" : "F") : null;
                    worksheet.Cell(currentRow, 8).Value = item.I_CredDesaprob;
                    worksheet.Cell(currentRow, 9).SetValue<string>(item.T_Message);
                    worksheet.Cell(currentRow, 10).Value = "F";
                }
                #endregion

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de alumnos.xlsx");
                }
            }
        }

        [Authorize(Roles = "Administrador")]
        [HttpPost]
        public ActionResult CargarArchivoMulta(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            var result = _seleccionarArchivoModel.CargarMultasPorNoVotar(Server.MapPath("~/Upload/MultaNoVotar/"), file, WebSecurity.CurrentUserId);

            var response = Mapper.MultaNoVotarResponse_To_Response(result);

            Session["MULTAS_SIN_REGISTRAR_RESPONSE"] = result.MultasSinRegistrar;

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [Authorize(Roles = "Administrador")]
        public ActionResult DescargarMultasSinRegistrar()
        {
            if (Session["MULTAS_SIN_REGISTRAR_RESPONSE"] == null)
                return RedirectToAction("cargar-estudiantes", "operaciones");

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Students");
                var currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Año";
                worksheet.Cell(currentRow, 2).Value = "P";
                worksheet.Cell(currentRow, 3).Value = "Cod_alu";
                worksheet.Cell(currentRow, 4).Value = "Cod_rc";
                worksheet.Cell(currentRow, 5).Value = "Observación";
                #endregion

                #region Body
                foreach (var item in (List<Domain.Entities.MultaNoVotarSinRegistrarEntity>)Session["MULTAS_SIN_REGISTRAR_RESPONSE"])
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).Value = item.I_Anio;
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.C_Periodo);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.C_CodAlu);
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.C_CodRC);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.T_Message);
                }
                #endregion

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Resultado del registro de multas.xlsx");
                }
            }
        }

        [Route("consulta/estudiantes")]
        public ActionResult Consulta(ConsultaObligacionEstudianteViewModel model)
        {
            ViewBag.Title = "Consulta de Estudiantes";

            if (model.anio.HasValue)
            {
                switch (model.tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        model.resultado = reportePregradoServiceFacade.EstadoObligacionAlumnos(
                            model.anio.Value, model.periodo, model.codRc, model.esIngresante, model.estaPagado, model.obligacionGenerada, model.fechaInicio, model.fechaFin);

                        if (!String.IsNullOrEmpty(model.codFac))
                        {
                            model.resultado = model.resultado.Where(x => x.C_CodFac.Equals(model.codFac));
                        }

                        break;
                    case TipoEstudio.Posgrado:
                        model.resultado = reportePosgradoServiceFacade.EstadoObligacionAlumnos(
                            model.anio.Value, model.periodo, model.codRc, model.esIngresante, model.estaPagado, model.obligacionGenerada, model.fechaInicio, model.fechaFin);

                        break;
                }

                if (!String.IsNullOrEmpty(model.codAlumno) && !String.IsNullOrWhiteSpace(model.codAlumno))
                {
                    model.resultado = model.resultado.Where(m => m.C_CodAlu.Equals(model.codAlumno));
                }
            }

            ViewBag.Anios = new SelectList(generalServiceFacade.Listar_Anios(), "Value", "TextDisplay", model.anio.HasValue ? model.anio.Value : DateTime.Now.Year);
            ViewBag.Periodos = new SelectList(catalogoServiceFacade.Listar_Periodos(), "Value", "TextDisplay", model.periodo);
            ViewBag.TipoEstudios = new SelectList(generalServiceFacade.Listar_TipoEstudios(), "Value", "TextDisplay", model.tipoEstudio);
            ViewBag.Dependencias = new SelectList(programasClientFacade.GetDependencias(model.tipoEstudio), "Value", "TextDisplay", model.codFac);
            ViewBag.Escuelas = new SelectList(programasClientFacade.GetEscuelas(model.codFac), "Value", "TextDisplay", model.codEsc);
            ViewBag.Especialidades = new SelectList(programasClientFacade.GetEspecialidades(model.codFac, model.codEsc), "Value", "TextDisplay", model.codRc);

            ViewBag.TipoAlumno = new SelectList(generalServiceFacade.Listar_TipoAlumno(), "Value", "TextDisplay", model.esIngresante);
            ViewBag.ExistenciaObligaciones = new SelectList(generalServiceFacade.Listar_CondicionExistenciaObligaciones(), "Value", "TextDisplay", model.obligacionGenerada);
            ViewBag.EstadoPagoObligaciones = new SelectList(generalServiceFacade.Listar_CondicionPagoObligacion(), "Value", "TextDisplay", model.estaPagado);

            ViewBag.FiltroDependencias = (model.tipoEstudio == TipoEstudio.Posgrado) ? null : "TODOS";

            return View("Consulta", model);
        }
    }
}