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
    public interface IProgramaUnfvRepository
    {
        ResponseData Create(USP_I_GrabarCarreraProfesional paramGrabarCarreraProfesional, USP_I_GrabarProgramaUnfv paramGrabarProgramaUnfv);

        ResponseData Edit(USP_U_ActualizarCarreraProfesional paramActualizarCarreraProfesional, USP_U_ActualizarProgramaUnfv paramActualizarProgramaUnfv);

        IEnumerable<VW_ProgramaUnfv> GetAll();

        VW_ProgramaUnfv GetByID(string codProg);

        VW_ProgramaUnfv GetByCodRc(string codRc);
    }
}
