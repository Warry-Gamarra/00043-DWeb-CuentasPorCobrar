using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public interface IProgramaServiceFacade
    {
        IEnumerable<FacultadModel> GetFacultades();

        FacultadModel GetFacultadByID(string codFac);

        IEnumerable<EscuelaModel> GetEscuelasByFac(string codFac);

        EscuelaModel GetEscuelaByID(string codEsc, string codFac);

        IEnumerable<EspecialidadModel> GetEspecialidadesByEsc(string codEsc, string codFac);

        EspecialidadModel GetEspecialidadByID(string codEsp, string codEsc, string codFac);
    }
}