using Autofac;
using Data.Repositories;
using Data.Repositories.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain
{
    public class CoreLibModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            builder.RegisterType<AlumnoRepository>().As<IAlumnoRepository>().SingleInstance();
            builder.RegisterType<PersonaRepository>().As<IPersonaRepository>().SingleInstance();
            builder.RegisterType<ProgramaUnfvRepository>().As<IProgramaUnfvRepository>().SingleInstance();
            builder.RegisterType<CarreraProfesionalRepository>().As<ICarreraProfesionalRepository>().SingleInstance();
        }
    }
}
