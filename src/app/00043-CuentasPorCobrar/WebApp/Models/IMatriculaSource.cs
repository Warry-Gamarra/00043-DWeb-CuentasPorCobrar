using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebApp.Models
{
    public interface IMatriculaSource
    {
        List<MatriculaEntity> GetList(TipoAlumno tipoAlumno, string filePath);
    }
}
