using Data.DTO;
using Data.Procedures;
using Data.Tables;
using Data.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IAlumnoRepository
    {
        ResponseData Create(USP_I_GrabarPersona paramGrabarPersona, USP_I_GrabarAlumno paramGrabarAlumno);

        ResponseData Edit(USP_U_ActualizarPersona paramActualizarPersona, USP_U_ActualizarAlumno paramActualizarAlumno);

        IEnumerable<VW_Alumnos> GetAll();

        VW_Alumnos GetByID(string codRc, string codAlu);

        IEnumerable<VW_Alumnos> GetByDocIdent(string codTipDoc, string numDNI);
    }
}
