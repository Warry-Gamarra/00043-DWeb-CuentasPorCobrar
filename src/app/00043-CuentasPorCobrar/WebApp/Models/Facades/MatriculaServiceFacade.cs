using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class MatriculaServiceFacade : IMatriculaServiceFacade
    {
        IEstudianteService _estudianteService;

        public MatriculaServiceFacade()
        {
            _estudianteService = new EstudianteService();
        }

        public MatriculaModel GetMatricula(int anio, int periodo, string codAlu, string codRc)
        {
            var matricula = _estudianteService.GetMatricula(anio, periodo, codAlu, codRc);

            var result = Mapper.MatriculaDTO_To_MatriculaModel(matricula);

            return result;
        }

        public IEnumerable<MatriculaModel> GetMatriculas(int anio, int periodo, TipoEstudio tipoEstudio)
        {
            IEnumerable<MatriculaDTO> matriculas;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    matriculas = _estudianteService.GetMatriculaPregrado(anio, periodo);
                    break;
                case TipoEstudio.Posgrado:
                    matriculas = _estudianteService.GetMatriculaPosgrado(anio, periodo);
                    break;
                default:
                    matriculas = new List<MatriculaDTO>();
                    break;
            }


            var result = matriculas.Select(m => Mapper.MatriculaDTO_To_MatriculaModel(m));

            return result;
        }
    }
}