using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Domain.Services
{
    public interface IEstudianteService
    {
        DataMatriculaResponse GrabarMatriculas(List<MatriculaEntity> tipoAlumno, bool alumnosPregado, int currentUserId);

        IEnumerable<MatriculaDTO> GetMatriculaPregrado(int anio, int periodo);

        IEnumerable<MatriculaDTO> GetMatriculaPosgrado(int anio, int periodo);

        MultaNoVotarResponse GrabarMultas(List<AlumnoSinVotoEntity> alumnoSinVotoEntity, int currentUserId);
    }
}
