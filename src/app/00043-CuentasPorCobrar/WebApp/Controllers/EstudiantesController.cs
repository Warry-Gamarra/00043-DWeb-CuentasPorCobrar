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
    [Authorize]
    public class EstudiantesController : Controller
    {
        private readonly EstudianteModel _seleccionarArchivoModel;

        IGeneralServiceFacade generalServiceFacade;
        ICatalogoServiceFacade catalogoServiceFacade;
        IProgramasClientFacade programasClientFacade;
        IMatriculaServiceFacade matriculaServiceFacade;

        public EstudiantesController()
        {
            _seleccionarArchivoModel = new EstudianteModel();
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            programasClientFacade = new ProgramasClientFacade();
            matriculaServiceFacade = new MatriculaServiceFacade();
        }

        [Route("operaciones/cargar-estudiantes")]
        public ActionResult Index()
        {
            ViewBag.Title = "Carga de Alumnos";

            return View();
        }

        [Route("operaciones/cargar-aptos-pregrado")]
        public ActionResult CargarArchivoMatriculaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Route("operaciones/cargar-aptos-posgrado")]
        public ActionResult CargarArchivoMatriculaPosgrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }


        [Route("operaciones/cargar-multas-pregrado")]
        public ActionResult CargarArchivoMultaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.MultaNoVotar);
            return PartialView("_SeleccionarArchivo", model);
        }

        [HttpPost]
        public ActionResult CargarArchivoMatricula(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            var result = _seleccionarArchivoModel.CargarMatricula(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            var response = Mapper.DataMatriculaResponse_To_Response(result);

            Session["MATRICULA_RESPONSE"] = result.DataMatriculasObs;

            return Json(response, JsonRequestBehavior.AllowGet);
        }
       
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

        [HttpPost]
        public ActionResult CargarArchivoMulta(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            var result = _seleccionarArchivoModel.CargarMultasPorNoVotar(Server.MapPath("~/Upload/MultaNoVotar/"), file, WebSecurity.CurrentUserId);

            var response = Mapper.MultaNoVotarResponse_To_Response(result);

            Session["MULTAS_SIN_REGISTRAR_RESPONSE"] = result.MultasSinRegistrar;

            return Json(response, JsonRequestBehavior.AllowGet);
        }

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
        public ActionResult Consulta(int? anio, int? periodo, string dependencia, string codAlumno, TipoEstudio tipoEstudio = TipoEstudio.Pregrado)
        {
            ViewBag.Title = "Consulta de Estudiantes";

            //Listas
            ViewBag.Anios = generalServiceFacade.Listar_Anios();
            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();
            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();
            ViewBag.Dependencias = programasClientFacade.GetFacultades(tipoEstudio);

            //Valores por defecto
            ViewBag.CurrentYear = anio.HasValue ? anio.Value : DateTime.Now.Year;
            ViewBag.DefaultPeriodo = periodo.HasValue ? periodo.Value : 15;
            ViewBag.DefaultTipoEstudio = tipoEstudio;
            ViewBag.DefaultDependencia = dependencia;
            ViewBag.CodigoAlumno = codAlumno;

            IEnumerable<MatriculaModel> consultaMatricula;

            if (anio.HasValue && periodo.HasValue)
                consultaMatricula = matriculaServiceFacade.GetMatriculas(anio.Value, periodo.Value, tipoEstudio);
            else
                consultaMatricula = new List<MatriculaModel>();

            if (!String.IsNullOrEmpty(dependencia) && !String.IsNullOrWhiteSpace(dependencia))
            {
                if (tipoEstudio.Equals(TipoEstudio.Pregrado))
                    consultaMatricula = consultaMatricula.Where(m => m.C_CodFac.Equals(dependencia));
                
                if (tipoEstudio.Equals(TipoEstudio.Posgrado))
                    consultaMatricula = consultaMatricula.Where(m => m.C_CodEsc.Equals(dependencia));
            }

            if (!String.IsNullOrEmpty(codAlumno) && !String.IsNullOrWhiteSpace(codAlumno))
            {
                consultaMatricula = consultaMatricula.Where(m => m.C_CodAlu.Equals(codAlumno));
            }

            return View("Consulta", consultaMatricula);
        }
    }
}