using Domain.Helpers;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;
using Domain.Services.Implementations;
using System.IO;

namespace WebApp.Models
{
    public class EstudianteModel
    {
        private IEstudianteService _estudiante;

        public EstudianteModel()
        {
            _estudiante = new EstudianteService();
        }

        public SeleccionarArchivoViewModel Init(TipoAlumno tipoAlumno, TipoArchivoAlumno tipoArchivoAlumno)
        {
            var result = new SeleccionarArchivoViewModel();
            string tipo = "";

            result.TipoAlumno = tipoAlumno;
            result.TipoArchivoAlumno = tipoArchivoAlumno;

            switch (tipoAlumno)
            {
                case TipoAlumno.Pregrado:
                    result.Color = "info";
                    break;
                case TipoAlumno.Posgrado:
                    result.Color = "primary";
                    break;
            }

            switch (tipoArchivoAlumno)
            {
                case TipoArchivoAlumno.Matricula:
                    tipo = "Matricula";
                    break;
                case TipoArchivoAlumno.MultaNoVotar:
                    tipo = "Multa";
                    break;
            }

            result.Action = "CargarArchivo" + tipo;

            return result;
        }

        public DataMatriculaResponse CargarMatricula(string serverPath, HttpPostedFileBase file, TipoAlumno tipoAlumno, int currentUserId)
        {
            if (file == null)
            {
                return new DataMatriculaResponse()
                {
                    Message = "No existe archivo seleccionado."
                };
            }

            DataMatriculaResponse response;
            string fileName = "";

            try
            {
                fileName = GuardarArchivoEnHost(serverPath, file);

                response = GuardarDatosRepositorio(serverPath + fileName, tipoAlumno, currentUserId);
            }
            catch (Exception ex)
            {
                response = new DataMatriculaResponse()
                {
                    Message = ex.Message
                };
            }
            finally
            {
                RemoverArchivo(serverPath, fileName);
            }

            return response;
        }

        private string GuardarArchivoEnHost(string serverPath, HttpPostedFileBase file)
        {
            try
            {
                string fileName = Guid.NewGuid() + "_" + Path.GetFileName(file.FileName);

                file.SaveAs(serverPath + fileName);

                return fileName;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private DataMatriculaResponse GuardarDatosRepositorio(string filePath, TipoAlumno tipoAlumno, int currentUserId)
        {
            var matriculaSource = MatriculaSourceFactory.Get(Path.GetExtension(filePath));

            var dataMatriculas = matriculaSource.GetList(filePath);

            bool alumnosPregado = (tipoAlumno == TipoAlumno.Pregrado);

            var result = _estudiante.GrabarMatriculas(dataMatriculas, alumnosPregado, currentUserId);

            return result;
        }

        private void RemoverArchivo(string serverPath, string fileName)
        {
            try
            {
                File.Delete(serverPath + fileName);
            }
            catch (Exception) { }
        }

        public MultaNoVotarResponse CargarMultasPorNoVotar(string serverPath, HttpPostedFileBase file, int currentUserId)
        {
            if (file == null)
            {
                return new MultaNoVotarResponse()
                {
                    Message = "No existe archivo seleccionado"
                };
            }

            MultaNoVotarResponse response;
            string fileName = "";
            
            try
            {
                fileName = GuardarArchivoEnHost(serverPath, file);

                response = GuardarDatosRepositorio(serverPath + fileName, currentUserId);
            }
            catch (Exception ex)
            {
                response = new MultaNoVotarResponse()
                {
                    Message = ex.Message
                };
            }
            finally
            {
                RemoverArchivo(serverPath, fileName);
            }

            return response;
        }

        private MultaNoVotarResponse GuardarDatosRepositorio(string filePath, int currentUserId)
        {
            var alumnosSinVotoSoruce = AlumnosSinVotoSourceFactory.Get(Path.GetExtension(filePath));

            var alumnosSinVoto = alumnosSinVotoSoruce.GetList(filePath);

            var result = _estudiante.GrabarMultas(alumnosSinVoto, currentUserId);

            return result;
        }
    }
}