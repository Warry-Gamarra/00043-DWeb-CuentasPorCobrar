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

        IEnumerable<CarreraProfesionalModel> GetCarrerasProfesionalesByFac(string codFac);

        IEnumerable<CarreraProfesionalModel> GetCarrerasProfesionalesByEsc(string codEsc, string codFac);

        CarreraProfesionalModel GetCarreraProfesionalByID(string codRc);

        ServiceResponse GrabarProgramaUnfv(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID);

        ServiceResponse EditarProgramaUnfv(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID);

        IEnumerable<ProgramaUnfvModel> GetProgramasUnfv();

        ProgramaUnfvModel GetProgramaUnfvByID(string codProg);

        ProgramaUnfvModel GetProgramaUnfvByCodRc(string codRc);

        IEnumerable<CarreraProfesionalModel> GetCarrerasProfesionales();
    }
}