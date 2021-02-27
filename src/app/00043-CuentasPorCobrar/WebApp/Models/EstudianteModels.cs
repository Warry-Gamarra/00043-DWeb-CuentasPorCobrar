using Domain.DTO;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class SeleccionarArchivoModel
    {
        private readonly IEstudiante _estudiante;

        public SeleccionarArchivoModel()
        {
            _estudiante = new Estudiante();
        }

        public SeleccionarArchivoViewModel Init(TipoAlumno tipoAlumno, TipoArchivoAlumno tipoArchivoAlumno)
        {
            var result = new SeleccionarArchivoViewModel();
            string grado = "";
            string tipo = "";

            result.TipoAlumno = tipoAlumno;
            result.TipoArchivoAlumno = tipoArchivoAlumno;

            switch (tipoAlumno)
            {
                case TipoAlumno.Pregrado:
                    result.Color = "info";
                    grado = "Pregrado";
                    break;
                case TipoAlumno.Posgrado:
                    result.Color = "primary";
                    grado = "Posgrado";
                    break;
                case TipoAlumno.Euded:
                    result.Color = "secondary";
                    grado = "Pregrado";
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

            result.Action = "CargarArchivo" + tipo + grado;

            return result;
        }

        public DataMatriculaResponse CargarAlumnosAptos(string pathFile, HttpPostedFileBase file, TipoAlumno tipoAlumno, int currentUserId)
        {
            if (file == null)
            {
                return new DataMatriculaResponse()
                {
                    Message = "No existe archivo seleccionado."
                };
            }

            return _estudiante.CargarDataAptos(pathFile, file, tipoAlumno, currentUserId);
        }
    }
}