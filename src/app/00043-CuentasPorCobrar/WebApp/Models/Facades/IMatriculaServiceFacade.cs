using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IMatriculaServiceFacade
    {
        IEnumerable<MatriculaModel> GetMatriculas(int anio, int periodo, TipoEstudio tipoEstudio);

        string GetNombresCompletos(string codAlu);
    }
}